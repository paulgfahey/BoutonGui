%{
# mouse.Hash (manual) 
animal_id                            : int                           # mouse identifying number
site_id                             : int                           # site identifying number
---
hash                                : varchar(255)                  # identifying hash for blinding investigator
%}


classdef Hash < dj.Manual    
end

