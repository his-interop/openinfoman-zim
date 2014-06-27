import module namespace dxf = "http://dhis2.org/schema/dxf/1.0" at "dxf_1_0.xqm";

<csd:CSD xmlns:csd="urn:ihe:iti:csd:2013">
	<csd:organisationDirectory>
	{
  for $orgUnit in /dxf:dxf/dxf:organisationUnits/dxf:organisationUnit
      let $displayName:=$orgUnit/dxf:name/text()
      let $uid:=$orgUnit/dxf:uid/text()
      let $level := dxf:orgunit_get_level(/,$orgUnit)
      where (($level = 1) or ($level = 2) or ($level = 3))
      return 
        	<csd:organization oid="{$uid}">
		<csd:codedType code="{$level}" codingScheme="dhis.mohcc.gov.zw:orglevel"/>
		<csd:primaryName>{$displayName}</csd:primaryName>
	{
		if (($level = 2) or( $level = 3)) then
		let $parent := dxf:get_parent(/,$orgUnit)
		let $puid := $parent/dxf:uid/text()
		return
			<csd:parent oid="{$puid}"/>
		else()
	}
	</csd:organization>
(:	where (($level = 4) or ($level = 5))
		let $has_children := dxf:get_children(/, $orgUnit)
		return if fn:empty($hasChildren)
		else
	 
		<csd:organization oid="{$uid}">
		<csd:codedType code="{$level}" codingScheme="dhis.mohcc.gov.zw:orglevel"/>
		<csd:primaryName>{$displayName}</csd:primaryName>
		
:)

      }
    </csd:organisationDirectory>
</csd:CSD>


