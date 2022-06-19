% Dotenv Implementation of dotenv pattern
% Source code: https://github.com/mathworks/dotenv-for-MATLAB
% NOTE - the source code has been edited to fallback to a general
% environment variable if the key is not found in the env file

classdef dotenv
    properties (SetAccess = immutable)
        env % Structure to hold key/value pairs. Access via d.env.key.
    end
    
    properties (Access = private)
        fname
    end
    
    methods
        function obj = dotenv(location)
            % d = dotenv([path/to/file.env]) -- load .env file from current working directory or specified via path.
            obj.env = struct;
            switch nargin
                case 1 % if there is an argument load that file
                    obj.fname = location;
                case 0 % otherwise load the file from the current directory
                    obj.fname = '.env';
            end
            
            % ensure we can open the file
            try
                fid = fopen(obj.fname, 'r');
                assert(fid ~= -1);
            catch
                throw( MException('DOTENV:CannotOpenFile', "Cannot open file: " + obj.fname + ". Code: " + fid) );
            end
            fclose(fid);
            
            % load the .env file with name=value pairs into the 'env' struct
            if verLessThan('matlab', '9.10')
                lines = string(splitlines(fileread(obj.fname)));
            else
                lines = readlines(obj.fname); 
            end
            
            notOK = startsWith(lines, '#');
            lines(notOK) = [];
            
            % expr splits the line into a key / value pairs with regex
            % capture. It captures one or more characters up to the first
            % instance of an '=' in 'key' and then zero or more characters
            % into 'value'. 
            expr = "(?<key>.+?)=(?<value>.*)";
            kvpair = regexp(lines, expr, 'names');
            
            % Deal with single entry case where regexp does not return a
            % cell array
            if iscell(kvpair)
                kvpair(cellfun(@isempty, kvpair)) = [];
                kvpair = cellfun(@(x) struct('key', x.key, 'value', x.value), kvpair);
            end
            
            % to be able to use dot reference we need to convert it to a
            % structure
            obj.env = cell2struct(strtrim({kvpair.value}), [kvpair.key], 2);
            
        end
        
        function val = subsref(obj, s)
            % Overload subsref to handle d.env (all key/value pairs) vs. d.env.key (the value specified by the supplied key)
            if size(s, 2) == 1
                % this handles the case of d.env
                val=obj.env;
            else
                % this handles the case of d.env.KEY_NAME
                if isfield(obj.env, s(2).subs)
                    val = obj.env.(s(2).subs);
                else
                    % If there is no key in the environment file,
                    % look for an environment variable of that key (defaults to "")
                    val = getenv(s(2).subs);
                end
            end
        end
        
    end
    
end
