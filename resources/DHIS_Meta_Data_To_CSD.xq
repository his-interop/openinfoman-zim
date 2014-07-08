import module namespace dxf = "http://dhis2.org/schema/dxf/1.0" at "dxf_1_0.xqm";

declare namespace csd = "urn:ihe:iti:csd:2013";

let $orgUnits := /dxf:dxf/dxf:organisationUnits/dxf:organisationUnit
return 
<csd:CSD xmlns:csd="urn:ihe:iti:csd:2013">
  <csd:organisationDirectory>
    {
      for $orgUnit in $orgUnits
      let $displayName:=$orgUnit/dxf:name/text()
      let $uid:=$orgUnit/dxf:uid/text()
      let $level := dxf:orgunit_get_level(/,$orgUnit)
      return 
	if (($level < 4) or (($level = 4) and (count(dxf:get_children(/, $orgUnit)) >0))) 
	then
  	  <csd:organization oid="{$uid}">
	    <csd:codedType code="{$level}" codingScheme="dhis.mohcc.gov.zw:orglevel"/>
	    <csd:primaryName>{$displayName}</csd:primaryName>
	    {
	      if ($level > 1) 
	      then
		let $parent := dxf:get_parent(/,$orgUnit)
		let $puid := $parent/dxf:uid/text()
		return	<csd:parent oid="{$puid}"/>
	      else ()
             }
	   </csd:organization>
        else () 
      }
  </csd:organisationDirectory>
  <csd:facilityDirectory>
    {
      for $orgUnit in $orgUnits
      let $displayName:=$orgUnit/dxf:name/text()
      let $uid:=$orgUnit/dxf:uid/text()
      let $level := dxf:orgunit_get_level(/,$orgUnit)
      return 
	if ($level > 3) 
	then
	   <csd:facility oid="{$uid}">
	    <csd:codedType code="{$level}" codingScheme="dhis.mohcc.gov.zw:orglevel"/>
	    <csd:primaryName>{$displayName}</csd:primaryName>
	   </csd:facility>
	else ()
    }
  </csd:facilityDirectory>
</csd:CSD>


