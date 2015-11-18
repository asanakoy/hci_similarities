function [ progress_struct ] = init_progress_string(title, max_count, update_period)
%INIT_PROGRESS_STRING Summary of this function goes here
%   Detailed explanation goes here
num_width = 0;
x = max_count;
while x
    x = round(x / 10);
    num_width = num_width + 1;
end

progress_struct.format = sprintf(sprintf('%%%%0%dd/%%0%dd', num_width , num_width), max_count);
progress_str = sprintf(progress_struct.format, 0);
str_width = length(progress_str);
progress_struct.clean_symbols = repmat('\b', 1, str_width);


fprintf('%s %s', title, progress_str);

end

