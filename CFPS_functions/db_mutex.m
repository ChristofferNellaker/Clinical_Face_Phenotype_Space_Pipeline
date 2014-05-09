function returned_bool = db_mutex(operation, var_database)
% db_mutex('on', 'DB_lock_file')
% creates a unique mutex and returns 1 when ready
% db_mutex('off', 'DB_lock_file')
% releases the mutex returns 1 when done.
unqid = regexp(pwd, '/','split');
unqid = [unqid{numel(unqid)}, '.request'];
request_file = ['../', unqid];
queue_file = [var_database,'.queue'];

returned_bool = 0;
if isequal(operation, 'on')
	fileID = fopen(request_file,'w');
	fprintf(fileID,'');
	fclose(fileID);
	while true
        	if ~exist(queue_file, 'file')
            		pause(0.1);
	        else
			fileID = fopen(queue_file,'r');
                	next_in_queue = fgets(fileID);
	                fclose(fileID);
        	        if isequal(next_in_queue, unqid)
                	        break
	                else
        	                pause(0.1);
	                end
        	end
        end
	returned_bool = 1;
elseif isequal(operation, 'off')
        delete(request_file);
        returned_bool = 1;
else
    error(['db_mutex misused this is not a valid operation =>   ', operation])
end

end

