#!/usr/bin/env python3
"""
Build a cleaned EVM v2 deployments table from LayerZero metadata.json (no deps).

Rules:
- include ONLY chains with v2 deployments AND chainType == 'evm'
- add boolean isTestnet (environment == 'testnet')
- normalize nativeChainId/cgId/cmcId to strings
- map chainLayer: L1->1, L2->2, L3->3
- map chainStack: none->0, OP_STACK->1, ARB_STACK->2, AVALANCHE_STACK->3
- keep only ACTIVE chains
- drop rows with missing nativeChainId
- sort by isTestnet, then nativeChainId numerically (fallback to string)
- drop columns: stage, deadDVN
- write CSV without index
"""

import argparse, csv, json, sys
from typing import Any, Dict, Iterable, List, Optional, Tuple

def norm_str_id(v: Any) -> Optional[str]:
    if v is None: return None
    if isinstance(v, float): return str(int(v)) if v.is_integer() else str(v)
    if isinstance(v, int): return str(v)
    return str(v)

def addr(field_val: Any) -> Optional[str]:
    if field_val is None: return None
    if isinstance(field_val, dict): return field_val.get("address")
    return str(field_val)

def to_int_or_none(s: Optional[str]) -> Optional[int]:
    if s is None: return None
    try:
        return int(s)
    except Exception:
        return None

def build_rows(meta: Dict[str, Any]) -> List[Dict[str, Any]]:
    out: List[Dict[str, Any]] = []
    for chain_key, entry in meta.items():
        details = entry.get("chainDetails", {})
        if details.get("chainType") != "evm":
            continue

        deployments = entry.get("deployments", []) or []
        for d in deployments:
            if d.get("version") != 2:
                continue

            row = {
                # Identity
                "chainKey": chain_key,
                "chainName": entry.get("chainName"),
                "environment": entry.get("environment"),
                "chainStatus": details.get("chainStatus"),
                "nativeChainId": norm_str_id(details.get("nativeChainId")),
                "chainLayer": details.get("chainLayer"),
                "chainStack": details.get("chainStack"),
                # Currency
                "currency": (details.get("nativeCurrency") or {}).get("symbol"),
                "decimals": (details.get("nativeCurrency") or {}).get("decimals"),
                "cgId": norm_str_id((details.get("nativeCurrency") or {}).get("cgId")),
                "cmcId": norm_str_id((details.get("nativeCurrency") or {}).get("cmcId")),
                # v2 identifiers
                "eid": norm_str_id(d.get("eid")),
                "stage": d.get("stage"),
                # v2 contracts
                "endpointV2": addr(d.get("endpointV2")),
                "endpointV2View": addr(d.get("endpointV2View")),
                "executor": addr(d.get("executor")),
                "lzExecutor": addr(d.get("lzExecutor")),
                "sendUln302": addr(d.get("sendUln302")),
                "receiveUln302": addr(d.get("receiveUln302")),
                "blockedMessageLib": addr(d.get("blockedMessageLib")),
                "deadDVN": addr(d.get("deadDVN")),
            }
            out.append(row)
    return out

def transform(rows: List[Dict[str, Any]]) -> List[Dict[str, Any]]:
    layer_map = {"L1": 1, "L2": 2, "L3": 3}
    stack_map = {None: 0, "OP_STACK": 1, "ARB_STACK": 2, "AVALANCHE_STACK": 3}

    # Keep only ACTIVE
    rows = [r for r in rows if r.get("chainStatus") == "ACTIVE"]

    # Drop rows with missing nativeChainId
    rows = [r for r in rows if r.get("nativeChainId") is not None]

    # Add isTestnet, map chainLayer/chainStack, drop stage/deadDVN/chainStatus later
    for r in rows:
        r["isTestnet"] = (r.get("environment") == "testnet")
        r["chainLayer"] = layer_map.get(r.get("chainLayer"), r.get("chainLayer"))
        r["chainStack"] = stack_map.get(r.get("chainStack"), 0)

    # Sort by isTestnet then nativeChainId numerically (fallback to string)
    def sort_key(r: Dict[str, Any]) -> Tuple[int, Tuple[int, str]]:
        # bool sorts False(0) then True(1) already
        cid_str = r.get("nativeChainId")
        cid_num = to_int_or_none(cid_str)
        return (1 if r["isTestnet"] else 0, (cid_num if cid_num is not None else 0, cid_str or ""))

    rows.sort(key=sort_key)

    # Reorder columns and drop stage/deadDVN/chainStatus
    ordered: List[Dict[str, Any]] = []
    first = ["isTestnet", "nativeChainId"]
    rest = [
        "chainKey","chainName","environment","chainLayer","chainStack",
        "currency","decimals","cgId","cmcId","eid",
        "endpointV2","endpointV2View","executor","lzExecutor",
        "sendUln302","receiveUln302","blockedMessageLib"
    ]
    for r in rows:
        o = {}
        # boolean as lowercase string for CSV clarity
        o["isTestnet"] = "true" if r["isTestnet"] else "false"
        o["nativeChainId"] = r.get("nativeChainId")
        for k in rest:
            if k in ("stage","deadDVN","chainStatus"):
                continue
            o[k] = r.get(k)
        ordered.append(o)
    return ordered

def write_csv(rows: List[Dict[str, Any]], out_path: str) -> None:
    if not rows:
        # Still write headers for consistency
        headers = [
            "isTestnet","nativeChainId","chainKey","chainName","environment",
            "chainLayer","chainStack","currency","decimals","cgId","cmcId","eid",
            "endpointV2","endpointV2View","executor","lzExecutor",
            "sendUln302","receiveUln302","blockedMessageLib"
        ]
        with open(out_path, "w", newline="", encoding="utf-8") as f:
            csv.writer(f).writerow(headers)
        return
    headers = list(rows[0].keys())
    with open(out_path, "w", newline="", encoding="utf-8") as f:
        w = csv.DictWriter(f, fieldnames=headers, extrasaction="ignore")
        w.writeheader()
        w.writerows(rows)

def main() -> int:
    ap = argparse.ArgumentParser(description="Generate EVM v2 deployments CSV from LayerZero metadata.json (no deps)")
    ap.add_argument("input_json", help="Path to metadata.json")
    ap.add_argument("-o","--output_csv", default="evm_v2_deployments_active_final_clean.csv",
                    help="Output CSV path (default: %(default)s)")
    args = ap.parse_args()

    with open(args.input_json, "r", encoding="utf-8") as f:
        meta = json.load(f)

    rows = build_rows(meta)
    rows = transform(rows)
    write_csv(rows, args.output_csv)
    print(f"Wrote {len(rows)} rows -> {args.output_csv}")
    return 0

if __name__ == "__main__":
    sys.exit(main())
