#!/usr/bin/env python3
import sys, csv, json

FIELD_MAP = {
    "nativeChainId":"nativeChainId","eid":"eid","cmcId":"cmcId",
    "chainLayer":"chainLayer","chainStack":"chainStack","decimals":"decimals",
    "chainKey":"chainKey","chainName":"chainName","currency":"currency","cgId":"cgId",
    "endpointV2":"endpointV2","endpointV2View":"endpointV2View","executor":"executor",
    "lzExecutor":"lzExecutor","sendUln302":"sendUln302","receiveUln302":"receiveUln302",
    "blockedMessageLib":"blockedMessageLib",
}
NUMERIC = {"nativeChainId","eid","cmcId","chainLayer","chainStack","decimals"}

def to_i(s):
    s = (s or "").strip()
    try: return int(float(s)) if s else 0
    except: return 0

rows = []
reader = csv.DictReader(sys.stdin)
for row in reader:
    if not (row.get("nativeChainId") or "").strip():  # skip blanks
        continue
    out = {}
    for k_csv, k_row in FIELD_MAP.items():
        v = row.get(k_csv, "")
        out[k_row] = to_i(v) if k_csv in NUMERIC else v.strip()
    rows.append(out)

json.dump({"rows": rows}, sys.stdout)
