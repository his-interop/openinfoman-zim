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
     
      let $provs0 := if (exists($careServicesRequest/id/@oid))
	then csd_bl:filter_by_primary_id(/CSD/providerDirectory/*,$careServicesRequest/id)
      else ()   

      


      return if (count($provs0) = 1) then
        let $provider :=$provs0[1]
        let $resolved_facilities :=for $facility in $provider/facilities/facility
                                    let $resolved_facility :=/CSD/facilityDirectory/facility[@oid=$facility/@oid]
                                   return <resolvedFacility oid='{$resolved_facility/@oid}'>{$resolved_facility/*}</resolvedFacility>

        let $resolved_organizations :=for $organization in $provider/organizations/organization
                                    let $resolved_organization :=/CSD/organizationDirectory/organization[@oid=$organization/@oid]
                                     return <resolvedOrganization oid='{$resolved_organization/@oid}'>
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
	<provider oid='{$provider/@oid}'>
           {($provider/*,$extension)}
        </provider>
      else 
	 ()
    }     
  </providerDirectory>
</CSD>
