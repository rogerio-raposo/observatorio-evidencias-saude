#!/usr/bin/env python3
"""34 synthetic checks. No source query, network, DB, or factual event."""
import copy
import hashlib
import json
from pathlib import Path
from temporal_source_offline_contracts import pubmed, clinical, SCHEMA

ROOT=Path(__file__).resolve().parents[1]
FREEZE=ROOT/"artifacts/topi-n2-dcbti-01/phase-b"
BLOBS={
"pubmed-interface-v2.json":"8f61b25c3bca5bb4f4da38867371955aec0e05e4",
"pubmed-query-v1.txt":"6f783b731884e95ae92d8239366d9e404dc44310",
"clinicaltrials-interface-v2.json":"621ed0252c028a33b666494f49a70a62e570a15c",
"clinicaltrials-query-v2.txt":"e02987ce16c10cbb915499621de05fbfaee49930",
"measurement-design-b1r1.md":"b3dfe5f2c6509cd66941e5c8d422a7a8c49cdfcd"}
PIF=json.loads((FREEZE/"pubmed-interface-v2.json").read_text())
CIF=json.loads((FREEZE/"clinicaltrials-interface-v2.json").read_text())
QUERY=(FREEZE/"pubmed-query-v1.txt").read_text()
PREQ=dict(method="GET",endpoint=PIF["base_endpoint"]+"esearch.fcgi",
          params=dict(db="pubmed",term=QUERY,retmode="json",retmax=10000))
CREQ=dict(method="GET",endpoint=CIF["base_endpoint"]+"studies",
          params=dict(CIF["normalized_query_parameters"]))
PASS=[]
def check(label,test):
    if not test: raise AssertionError(label+" FAIL")
    PASS.append(label)
    print(label+" PASS")
def p(body,request=None):
    return pubmed(body,request if request is not None else PREQ,PIF,QUERY,"pubmed-synthetic",BLOBS["pubmed-interface-v2.json"])
def study(n,dates=True):
    x=dict(identificationModule=dict(nctId="NCT"+str(n).zfill(8),briefTitle="SYNTHETIC"),
           statusModule=dict(overallStatus="RECRUITING"))
    if dates:x["statusModule"]["studyFirstPostDateStruct"]=dict(date="2026-10-08")
    return dict(protocolSection=x)
def page(records=None,next_token=None,request_token=None):
    request=copy.deepcopy(CREQ)
    if request_token is not None:request["params"]["pageToken"]=request_token
    body={"studies":records if records is not None else []}
    if next_token is not None:body["nextPageToken"]=next_token
    return dict(request=request,body=body)
def c(pages):
    return clinical(pages,CIF,"clinicaltrials-synthetic",BLOBS["clinicaltrials-interface-v2.json"])
def es(n,ids):
    return {"esearchresult":{"count":str(n),"idlist":ids}}
def has(result,code):
    return code in result["issues"] and result["derived_complete_cardinality"] is None

# OFF-P01–P12
check("OFF-P01",p(es(0,[]))["derived_complete_cardinality"]==0)
check("OFF-P02",p(es(1,["123"]))["identifier_set"]==["123"])
check("OFF-P03",p(es(10000,[str(n) for n in range(1,10001)]))["derived_complete_cardinality"]==10000)
check("OFF-P04",has(p(es(10001,[])),"PUBMED_COUNT_OVER_LIMIT"))
check("OFF-P05",has(p(es(2,["1"])),"COUNT_IDLIST_MISMATCH"))
check("OFF-P06",has(p(es(1,["1","2"])),"COUNT_IDLIST_MISMATCH"))
check("OFF-P07",has(p(es(2,["1","1"])),"DUPLICATE_IDENTIFIER"))
check("OFF-P08",all(has(p(es(n,[])),"INVALID_COUNT") for n in ("-1","x",True)))
check("OFF-P09",has(p("{oops"),"INVALID_JSON"))
check("OFF-P10",has(p({"error":"offline","esearchresult":{"count":"0","idlist":[]}}),"SOURCE_ERROR"))
bad=copy.deepcopy(PREQ);bad["params"]["reldate"]=30
check("OFF-P11",has(p(es(0,[]),bad),"REQUEST_CONTRACT_DRIFT"))
check("OFF-P12",p(es(1,["123"]))==p(json.dumps(es(1,["123"]))))

# OFF-C01–C16
check("OFF-C01",c([page()])["derived_complete_cardinality"]==0)
check("OFF-C02",c([page([study(1)])])["identifier_set"]==["NCT00000001"])
check("OFF-C03",c([page([study(1)],"T1"),page([study(2)],request_token="T1")])["derived_complete_cardinality"]==2)
check("OFF-C04",len(c([page([study(1)],"T1"),page([study(2)],"T2","T1"),page([study(3)],request_token="T2")])["page_trace"])==3)
check("OFF-C05",has(c([page([study(1)],"next")]),"PAGINATION_INCOMPLETE"))
check("OFF-C06",has(c([page([study(1)],"again"),page([study(2)],"again","again")]),"PAGE_TOKEN_CYCLE"))
check("OFF-C07",has(c([page([study(1)]," ")]),"INVALID_PAGE_TOKEN"))
check("OFF-C08",has(c([page([study(1),study(1)])]),"DUPLICATE_IDENTIFIER"))
check("OFF-C09",has(c([page([study(1)],"a"),page([study(1)],request_token="a")]),"DUPLICATE_IDENTIFIER"))
check("OFF-C10",has(c([dict(request=CREQ,body={"studies":"bad"})]),"INVALID_STUDIES"))
check("OFF-C11",has(c([page([{"protocolSection":{"identificationModule":{}}}])]),"INVALID_NCT_ID"))
check("OFF-C12",has(c([dict(request=CREQ,body="{oops")]),"INVALID_JSON"))
errorpage=dict(request={**CREQ,"params":{**CREQ["params"],"pageToken":"next"}},transport_error="timeout")
check("OFF-C13",has(c([page([study(1)],"next"),errorpage]),"TRANSPORT_ERROR"))
check("OFF-C14",has(c([dict(request=CREQ,transport_error="timeout")]),"TRANSPORT_ERROR"))
check("OFF-C15",has(c([page([study(1)],"next"),page([study(2)],request_token="wrong")]),"REQUEST_CONTRACT_DRIFT"))
res=c([page([study(1,False)])])
check("OFF-C16",res["retrieval_completeness"]=="complete" and "StudyFirstPostDate" not in res["minimal_records"][0])

# OFF-X01–X06
def blob(data):
    return hashlib.sha1(b"blob "+str(len(data)).encode()+bytes([0])+data).hexdigest()
check("OFF-X01",all(blob((FREEZE/name).read_bytes())==sha for name,sha in BLOBS.items()))
module=(ROOT/"scripts/temporal_source_offline_contracts.py").read_text()
check("OFF-X02",all(term not in module for term in ("import requests","urllib.request","urlopen(","socket.","http.client")))
check("OFF-X03",all(term not in module for term in ("psycopg","sqlite3","INSERT INTO","UPDATE maintenance.")))
r=p(es(0,[]))
check("OFF-X04",r["schema_version"]==SCHEMA and r["synthetic_test_only"] and
      all(key not in r for key in ("execution_status","execution_started_at","MeasurementEvent","OpportunityResolution")))
r=c([page([study(1)],"next")])
check("OFF-X05",r["retrieval_completeness"]!="complete" and r["derived_complete_cardinality"] is None)
check("OFF-X06",c([page([study(1)])])==c([page([study(1)])]) and
      "current_timestamp" not in json.dumps(c([page([study(1)])])).lower())
if len(PASS)!=34 or len(set(PASS))!=34:raise AssertionError("expected exactly 34 tests")
print("F4-OFFLINE-SOURCE-CONTRACTS PASS — OFF-P01–P12 OFF-C01–C16 OFF-X01–X06 (34/34)")
