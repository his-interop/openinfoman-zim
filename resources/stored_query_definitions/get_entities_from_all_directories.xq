import module namespace csd_dm = "https://github.com/openhie/openinfoman/csd_dm";

import module namespace csd_bl = "https://github.com/openhie/openinfoman/csd_bl";
declare   namespace   csd = "urn:ihe:iti:csd:2013";
declare default element  namespace   "urn:ihe:iti:csd:2013";
declare variable $careServicesRequest as item() external;



let $doc_names := csd_dm:registered_documents()  

let $csds :=for $doc_name in $doc_names
            let $doc := csd_dm:open_document($doc_name)
            let $provs:= if(exists($careServicesRequest/csd:requestParams/commonName))
	    then csd_bl:filter_by_common_name($doc/CSD/providerDirectory/*,$careServicesRequest/csd:requestParams/commonName)
            else ()

            let $facs :=  if (exists($careServicesRequest/csd:requestParams/commonName))
	then csd_bl:filter_by_primary_name($doc/CSD/facilityDirectory/*,$careServicesRequest/csd:requestParams/commonName)
      else ()

          
           return <CSD>
                    <providerDirectory>{$provs}</providerDirectory>
                    <facilityDirectory>{$facs}</facilityDirectory>                  
                 </CSD>


return <CSD>
           <providerDirectory>
               {
                  for $csd in $csds
                   return $csd/providerDirectory/*
               }
           </providerDirectory>

           <facilityDirectory>
              {
                  for $csd in $csds
                   return $csd/facilityDirectory/*
               }
           </facilityDirectory>

           <organizationDirectory>
              {
                  for $csd in $csds
                   return $csd/organizationDirectory/*
               }
           </organizationDirectory>


</CSD>
                


                 
                  






      
 


