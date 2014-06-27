import module namespace csd_dm = "https://github.com/his-interop/openinfoman/csd_dm";
import module namespace csd_webconf =  "https://github.com/his-interop/openinfoman/csd_webconf";
import module namespace csd_lsc = "https://github.com/his-interop/openinfoman/csd_lsc";
declare default element  namespace   "urn:ihe:iti:csd:2013";

declare  variable $careServicesRequest as item() external;
 let $cache_doc :=/CSD/..
 return csd_lsc:refresh_doc($cache_doc ,$careServicesRequest/pushRequest)


