import module namespace csd_dm = "https://github.com/openhie/openinfoman/csd_dm";
import module namespace csd_bl = "https://github.com/openhie/openinfoman/csd_bl";
declare   namespace   csd = "urn:ihe:iti:csd:2013";
declare default element  namespace   "urn:ihe:iti:csd:2013";
declare variable $careServicesRequest as item() external;



let $doc_names := csd_dm:registered_documents()  

let $csds :=for $doc_name in $doc_names
            let $doc := csd_dm:open_document($doc_name)
            let $provs:=      
               if ($careServicesRequest/csd:requestParams/otherID/@code)
	         then csd_bl:filter_by_other_id($doc/CSD/providerDirectory/*,$careServicesRequest/csd:requestParams/otherID)
               else ()

            let $facs := if (count($provs) = 1) then
                          let $provider :=$provs[1]
                          return for $facility in $provider/facilities/facility
                                 return $doc/CSD/facilityDirectory/facility[upper-case(@entityID)=upper-case($facility/@entityID)]
                         else ()
            let $orgs :=if (count($provs) = 1) then
                          let $provider :=$provs[1]
                          return for $organization in $provider/organizations/organization
                                   return $doc/CSD/organizationDirectory/organization[upper-case(@entityID)=upper-case($organization/@entityID)]
                        else ()
           return <CSD>
                    <providerDirectory>{$provs}</providerDirectory>
                    <facilityDirectory>{$facs}</facilityDirectory>
                    <organizationDirectory>{$orgs}</organizationDirectory>                    
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
                


                 
                  






      
 


