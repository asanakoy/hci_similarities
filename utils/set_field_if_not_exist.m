function [ struct ] = set_field_if_not_exist(struct, fieldname, value)
%SET_FIELD_IF_NOT_EXIST Set field (fieldname) of the struct to value if the field was not previously set.

assert(isstruct(struct), 'Is not a struct!');

if ~isfield(struct, fieldname)
    struct.(fieldname) = value;
end

end

