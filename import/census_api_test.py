#using the Sunlight Labs Census API wrapper: https://github.com/sunlightlabs/census

from census import Census
from us import states

c = Census("395ecd145938bf526faf5070f0d3f717febbc467")
homes1939 = c.acs.get(('NAME', 'B25034_010E'), {'for': 'state:%s' % states.MD.fips})

print homes1939