import module namespace csd_dm = "https://github.com/openhie/openinfoman/csd_dm";
import module namespace csd_webconf =  "https://github.com/openhie/openinfoman/csd_webconf";
import module namespace csd_lsc = "https://github.com/openhie/openinfoman/csd_lsc";
declare default element  namespace   "urn:ihe:iti:csd:2013";

declare  variable $careServicesRequest as item() external;
 let $cache_doc :=/.
 return csd_lsc:refresh_doc($cache_doc ,$careServicesRequest/requestParams/pushRequest)


