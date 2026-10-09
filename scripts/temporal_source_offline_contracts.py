"""OES Fase 4 — deterministic offline synthetic parser contracts. No HTTP/SQL."""
import json
import re

SCHEMA = "oes.temporal_offline_source_parse_report/0.1"

def report(source, fixture, sha, match):
    return dict(schema_version=SCHEMA, synthetic_test_only=True, source_code=source,
                fixture_id=fixture, frozen_interface_blob_sha=sha,
                request_contract_match="match" if match else "mismatch",
                parse_state="valid", retrieval_completeness="indeterminate",
                observed_source_count=None, derived_complete_cardinality=None,
                identifier_set=[], minimal_records=[], page_trace=[], issues=[],
                evidence_paths=["tests/fixtures/f4-temporal-sources-offline/"+fixture+".json"])

def issue(r, code, invalid=False):
    if code not in r["issues"]: r["issues"].append(code)
    if invalid: r["parse_state"]="invalid"
    r["retrieval_completeness"]="incomplete"
    r["derived_complete_cardinality"]=None

def obj(data):
    value=json.loads(data) if isinstance(data,str) else data
    if not isinstance(value,dict): raise ValueError("expected object")
    return value

def pm_request(request, interface, query):
    expected=interface["normalized_query_parameters"]
    return (isinstance(request,dict) and request.get("method")=="GET"
        and request.get("endpoint")==interface["base_endpoint"]+interface["measurement_utility"]
        and request.get("params")=={"db":expected["db"],"term":query,"retmode":expected["retmode"],"retmax":expected["retmax"]})

def ct_request(request, interface, token=None):
    params=dict(interface["normalized_query_parameters"])
    if token is not None: params["pageToken"]=token
    return (isinstance(request,dict) and request.get("method")=="GET"
        and request.get("endpoint")==interface["base_endpoint"]+interface["measurement_endpoint"]
        and request.get("params")==params)

def pubmed(response, request, interface, query, fixture, sha):
    match=pm_request(request,interface,query)
    r=report("PUBMED_MEDLINE",fixture,sha,match)
    if not match: issue(r,"REQUEST_CONTRACT_DRIFT")
    try: value=obj(response)
    except (ValueError,TypeError): issue(r,"INVALID_JSON",True); return r
    if "error" in value or "ERROR" in value: issue(r,"SOURCE_ERROR")
    body=value.get("esearchresult")
    if not isinstance(body,dict): issue(r,"INVALID_ESEARCH_ENVELOPE",True); return r
    if "error" in body or "ERROR" in body: issue(r,"SOURCE_ERROR")
    count=body.get("count")
    if isinstance(count,bool) or not ((isinstance(count,int) and count>=0)
        or (isinstance(count,str) and re.fullmatch(r"[0-9]+",count))):
        issue(r,"INVALID_COUNT",True); return r
    count=int(count); r["observed_source_count"]=count
    if count>10000: issue(r,"PUBMED_COUNT_OVER_LIMIT")
    ids=body.get("idlist")
    if not isinstance(ids,list): issue(r,"INVALID_IDLIST",True); return r
    for value in ids:
        if isinstance(value,str) and re.fullmatch(r"[0-9]+",value): r["identifier_set"].append(value)
        else: issue(r,"INVALID_PMID",True)
    if len(set(r["identifier_set"]))!=len(r["identifier_set"]): issue(r,"DUPLICATE_IDENTIFIER")
    if len(ids)!=count: issue(r,"COUNT_IDLIST_MISMATCH")
    if "retstart" in body and str(body["retstart"])!="0": issue(r,"RESPONSE_OFFSET_MISMATCH")
    if "retmax" in body:
        try:
            limit=int(body["retmax"])
            if limit<0 or limit>10000 or limit<len(ids): issue(r,"RESPONSE_RETMAX_MISMATCH")
        except (ValueError,TypeError): issue(r,"RESPONSE_RETMAX_MISMATCH")
    if not r["issues"]:
        r["retrieval_completeness"]="complete"
        r["derived_complete_cardinality"]=len(r["identifier_set"])
    return r

def clinical(pages, interface, fixture, sha):
    r=report("CLINICALTRIALS_GOV",fixture,sha,True)
    if not isinstance(pages,list) or not pages: issue(r,"NO_PAGES"); return r
    expected=None; tokens=set(); identifiers=set(); terminal=False
    for number,page in enumerate(pages,1):
        if terminal: issue(r,"UNEXPECTED_EXTRA_PAGE"); break
        if not isinstance(page,dict): issue(r,"INVALID_PAGE",True); break
        if not ct_request(page.get("request"),interface,expected):
            issue(r,"REQUEST_CONTRACT_DRIFT"); r["request_contract_match"]="mismatch"
        if page.get("transport_error") is not None:
            issue(r,"TRANSPORT_ERROR")
            r["page_trace"].append(dict(page_no=number,request_token=expected,transport_error=True))
            break
        try: body=obj(page.get("body"))
        except (ValueError,TypeError): issue(r,"INVALID_JSON",True); break
        if "error" in body: issue(r,"SOURCE_ERROR")
        studies=body.get("studies")
        if not isinstance(studies,list): issue(r,"INVALID_STUDIES",True); break
        for study in studies:
            if not isinstance(study,dict): issue(r,"INVALID_STUDY_RECORD",True); continue
            protocol=study.get("protocolSection")
            if not isinstance(protocol,dict): issue(r,"INVALID_STUDY_RECORD",True); continue
            ident=protocol.get("identificationModule")
            ident=ident if isinstance(ident,dict) else {}
            nct=ident.get("nctId")
            if not isinstance(nct,str) or not re.fullmatch(r"NCT[0-9]{8}",nct):
                issue(r,"INVALID_NCT_ID",True); continue
            if nct in identifiers: issue(r,"DUPLICATE_IDENTIFIER")
            identifiers.add(nct); r["identifier_set"].append(nct)
            status=protocol.get("statusModule")
            status=status if isinstance(status,dict) else {}
            minimal={"NCTId":nct}
            for field,value in (("BriefTitle",ident.get("briefTitle")),("OverallStatus",status.get("overallStatus"))):
                if value is not None: minimal[field]=value
            for field,key in (("StudyFirstPostDate","studyFirstPostDateStruct"),
                              ("ResultsFirstPostDate","resultsFirstPostDateStruct"),
                              ("LastUpdatePostDate","lastUpdatePostDateStruct")):
                struct=status.get(key)
                if isinstance(struct,dict) and isinstance(struct.get("date"),str):
                    minimal[field]=struct["date"]
            r["minimal_records"].append(minimal)
        token=body.get("nextPageToken")
        if token is None: terminal=True
        elif not isinstance(token,str) or not token.strip(): issue(r,"INVALID_PAGE_TOKEN",True); break
        elif token in tokens or token==expected: issue(r,"PAGE_TOKEN_CYCLE"); break
        else: tokens.add(token)
        r["page_trace"].append(dict(page_no=number,request_token=expected,next_page_token=token))
        expected=token
    if not terminal: issue(r,"PAGINATION_INCOMPLETE")
    if not r["issues"]:
        r["retrieval_completeness"]="complete"
        r["derived_complete_cardinality"]=len(identifiers)
    return r
