import module namespace csd_bl = "https://github.com/openhie/openinfoman/csd_bl";
declare namespace   csd  =  "urn:ihe:iti:csd:2013";
declare namespace h  = "http://www.w3.org/1999/xhtml";
declare variable $careServicesRequest as item() external;

(: 
   The query will be executed against the root element of the CSD document.
    
   The dynamic context of this query has $careServicesRequest set to contain any of the search 
   and limit paramaters as sent by the Service Finder
:) 



(:lookup current deployment of a provider :)
let $get_current_deployment_province := function($provider)  {
  let $facs := $provider/csd:facilities/csd:facility
  let $start_dates :=  distinct-values($facs/csd:extension[@type='deployment_details' and @urn='urn:oid:2.25.62572576096234591446887698759906520253']/start_date)
  (:maybe no start_date data was uploaded yet:)
  let $fac:= if (count($start_dates) = 0) then
    $facs[1]
  else 
    let $max_start_date := max($start_dates)
    return ($facs[ ./csd:extension[@type='deployment_details' and @oid='urn:oid:2.25.62572576096234591446887698759906520253' and ./start_date = $max_start_date]])[1]
   (:now have the most current facility (hopefully).  now lookup province:)
  let $fac_record := /csd:CSD/csd:facilityDirectory/csd:facility[upper-case(@entityID) = upper-case($fac/@entityID)]
  let $province := ($fac_record/csd:address[@type='PHYSICAL']/csd:addressLine[@component='PROVINCE']/text())[1]
  return $province
}


(:
For a specified training program, get the count of all the health workers with that training program by province for trainings during the given start and end dates   
:)
let $get_trainings := function($training_program,$start_date,$end_date) {
  let $all_trainings := /csd:CSD/csd:providerDirectory/csd:provider/csd:extension[@type='in-service-training' and @oid='urn:oid:2.25.62572576096234591446887698759906520253']
  let $training_instances_0:= 
    if ($training_program) then  $all_trainings[./program/text() = $training_program]
    else $all_trainings
  (: we selected all instance of IST with specified training program :)
  let $training_instances_1 := 
    if ($start_date) then $training_instances_0[./start_date >= $start_date]
    else $training_instances_0
  let $training_instances_2 := 
    if ($end_date) then $training_instances_1[./end_date <= $end_date]
    else $training_instances_1

  let $training_programs := distinct-values($training_instances_2/program/text())

  return 
    for $tp in $training_programs
    let $instances := $training_instances_2[./program/text() =  $tp]
    let $hws := distinct-values($instances/..) (:same hw may take same program twice:)
    let $provinces := 
      distinct-values(for $hw in $hws return $get_current_deployment_province($hw))
    for $province in $provinces 
      let $hws_by_prov := 
         for $hw in $hws 
	 where $get_current_deployment_province($hw) = $province
         return $hw
      return <tr><td>{$tp}</td><td>{$province}</td><td>{count($hws_by_prov)}</td></tr>
   (:should optimize so don't calculate current province twice :)
}

let $custom_doc := 

<CSD xmlns:csd="urn:ihe:iti:csd:2013"  >
  <organizationDirectory/>
  <serviceDirectory/>
  <facilityDirectory/>
  <providerDirectory>
    {
      let $facility_entityID := $careServicesRequest/csd:requestParams/facilities/facility[1]/@entityID
      let $service_entityID := $careServicesRequest/csd:requestParams/facilities/facility[1]/service/@entityID
	  
      (: if no provider id was provided, then this is invalid. :)
      let $provs0 := if (exists($careServicesRequest/csd:requestParams/id))
	then csd_bl:filter_by_primary_id(/CSD/providerDirectory/*,$careServicesRequest/csd:requestParams/id)
      else ()   

      let $provs1 := if (exists($facility_entityID) and count($provs0) = 1)
	then 
	   if (count ($provs0[1]/facilities/facility[upper-case(@entityID) = upper-case($facility_entityID)]) > 0) then $provs0 else ()
	else $provs0

      let $provs2 := if (exists($service_entityID) and count($provs1) = 1)
	then 
	   if (count ($provs1[1]/facilities/facility[upper-case(@entityID) = upper-case($facility_entityID)]/service[upper-case(@entityID) = upper-case($service_entityID)]) > 0) then $provs1 else ()
	else $provs1

      return if (count($provs2) = 1) then
	<provider entityID='{$provs2[1]/@entityID}'/>
      else 
	 ()
    }     
  </providerDirectory>
</CSD>


return 
<h:html>
  <h:body>
  <h:h1>Training Distribution Report</h:h1>
  <h:div class='search_parameters'>
    <h:ul>
      <h:li>Start Date: {$careServicesRequest/csd:requestParams/start_date} </h:li>
      <h:li>End Date:  {$careServicesRequest/csd:requestParams/end_date} </h:li>
      <h:li>Funder:  {string($careServicesRequest/csd:requestParams/funding_institution/@code) } </h:li>
    </h:ul>
  </h:div>
  <h:div class='search_results'>
    <h:table>
      <h:tr>
        <h:th>Training Program</h:th>
        <h:th>Province</h:th>
        <h:th>Number of Health Workers</h:th>	
      </h:tr>
      {
	
	$get_trainings(
	    $careServicesRequest/csd:requestParams/training_program,
	    $careServicesRequest/csd:requestParams/start_date,
	    $careServicesRequest/csd:requestParams/end_date) 
      }
    </h:table>
  </h:div>
  </h:body>
</h:html>







