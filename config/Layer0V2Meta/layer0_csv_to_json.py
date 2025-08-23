#!/usr/bin/env python3
# Usage: cat layer0.csv | python3 ./layer0_csv_to_json.py [mainnet|testnet|all] > layer0.json
# Usage: cat layer0.csv | python3 ./layer0_csv_to_json.py mainnet > layer0_mainnet.json
# Usage: cat layer0.csv | python3 ./layer0_csv_to_json.py testnet > layer0_testnet.json
import sys, csv, json

ENV = (sys.argv[1].lower() if len(sys.argv) > 1 else "all")
FIELD_MAP = {
  "nativeChainId":"nativeChainId","eid":"eid","cmcId":"cmcId",
  "chainLayer":"chainLayer","chainStack":"chainStack","decimals":"decimals",
  "chainKey":"chainKey","chainName":"chainName","currency":"currency","cgId":"cgId",
  "endpointV2":"endpointV2","endpointV2View":"endpointV2View","executor":"executor",
  "lzExecutor":"lzExecutor","sendUln302":"sendUln302","receiveUln302":"receiveUln302",
  "blockedMessageLib":"blockedMessageLib"
}
NUMERIC = {"nativeChainId","eid","cmcId","chainLayer","chainStack","decimals"}

def to_i(s):
    s = (s or "").strip()
    try: return int(float(s)) if s else 0
    except: return 0

rows, rdr = [], csv.DictReader(sys.stdin)
for row in rdr:
    env = (row.get("environment") or "").strip().lower()
    if ENV != "all" and env != ENV: continue
    if not (row.get("nativeChainId") or "").strip(): continue
    out = {}
    for k_csv, k_row in FIELD_MAP.items():
        v = row.get(k_csv, "")
        out[k_row] = to_i(v) if k_csv in NUMERIC else v.strip()
    rows.append(out)

json.dump({"rows": rows}, sys.stdout, separators=(",", ":"))
sys.stdout.write("\n")
