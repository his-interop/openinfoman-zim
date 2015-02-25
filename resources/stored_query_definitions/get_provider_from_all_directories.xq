import module namespace csd_bl = "https://github.com/openhie/openinfoman/csd_bl";

declare default element  namespace   "urn:ihe:iti:csd:2013";
declare variable $careServicesRequest as item() external;

(: 
   The query will be executed against the root element of the CSD document.
    
   The dynamic context of this query has $careServicesRequest set to contain any of the search 
   and limit paramaters as sent by the Service Finder
:) 

<CSD xmlns:csd="urn:ihe:iti:csd:2013">
  <organizationDirectory/>
  <serviceDirectory/>
  <facilityDirectory/>
  <providerDirectory>
    {
      let $provs0 :=
         
           if ($careServicesRequest/otherID/@code)
	     then csd_bl:filter_by_other_id(/CSD/providerDirectory/*,$careServicesRequest/otherID)
           else ()   

      return if (count($provs0) = 1) then
        let $provider :=$provs0[1]
        let $resolved_facilities :=for $facility in $provider/facilities/facility
                                    let $resolved_facility :=/CSD/facilityDirectory/facility[upper-case(@entityID)=upper-case($facility/@entityID)]
                                   return <resolvedFacility entityID='{$resolved_facility/@entityID}'>{$resolved_facility/*}</resolvedFacility>

        let $resolved_organizations :=for $organization in $provider/organizations/organization
                                    let $resolved_organization :=/CSD/organizationDirectory/organization[upper-case(@entityID)=upper-case($organization/@entityID)]
                                     return <resolvedOrganization entityID='{$resolved_organization/@entityID}'>
                                              {$resolved_organization/*}
                                            </resolvedOrganization>

        let $extension :=if (count($resolved_facilities) >= 1 or count($resolved_organizations) >= 1) then 
                           <extension>
                            <providerAdditionals>
                                {($resolved_facilities,$resolved_organizations)}
                            </providerAdditionals>
                           </extension> 
                        else ()
         return
	<provider entityID='{$provider/@entityID}'>
           {($provider/*,$extension)}
        </provider>
      else 
	 ()
    }     
  </providerDirectory>
</CSD>
