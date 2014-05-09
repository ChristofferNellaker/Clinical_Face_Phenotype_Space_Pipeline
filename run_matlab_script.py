################################################################################
#
#   run_matlab_scripts.py
#
#   Copyright (c) 10/01/2013 Christoffer Nellaker
#   #   Permission is hereby granted, free of charge, to any person obtaining a copy
#   of this software and associated documentation files (the "Software"), to deal
#   in the Software without restriction, including without limitation the rights
#   to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#   copies of the Software, and to permit persons to whom the Software is
#   furnished to do so, subject to the following conditions:
#   #   The above copyright notice and this permission notice shall be included in
#   all copies or substantial portions of the Software.
#   #   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#   IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#   FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#   AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#   LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#   OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
#   THE SOFTWARE.
#################################################################################

import os, sys, tempfile, shutil, glob, random, time, re
from run_cmd import run_cmd
from restore_curr_dir import restore_curr_dir

def run_matlab_script(original_script_name, list_of_lines_to_add, mulitcore_matlab=False, queue_run=True, debug= False):    
    ############
    # create temp matlab script file
    fh_temp = tempfile.NamedTemporaryFile("w", prefix=os.path.abspath("./")+"/tmp_", suffix=".m", delete=False)
    fh_temp.write("\n".join(list_of_lines_to_add)+"\n")
    try: fh_temp.write("".join([x for x in open(original_script_name).readlines()]))
    except: pass
    temp_name = fh_temp.name
    fh_temp.close()
    if debug:
        print "\n\n\n\n\n", temp_name, "\n\n\n\n\n"
        sys.exit(1)
    ############
    # prepare run_cmd
    fgu217_queue = 'nice -19 qrsh -cwd -q fgu217.q -v BASH_ENV="~/.bashrc" -now n'
    matlab_run_cmd = '/net/isi-software/tools/matlab2011b/bin/matlab -nosplash -nodisplay -nojvm'
    single_core = '-singleCompThread'
    curr_script_to_run = '-r "%s; exit"' % (os.path.split(fh_temp.name)[1][:-2])
    curr_run_str_list = []
    if queue_run: curr_run_str_list.append(fgu217_queue) 
    curr_run_str_list.append(matlab_run_cmd)
    if not mulitcore_matlab: curr_run_str_list.append(single_core)
    curr_run_str_list.append(curr_script_to_run)
    
    curr_run_cmd = " ".join(curr_run_str_list)
    ############
    # run the script
    #print curr_run_cmd
    #sys.exit(1)
    run_cmd(curr_run_cmd, "running matlab scripts")
    ############
    # cleanup
    os.unlink(temp_name)

def compile_matlab_script(original_script_name, list_of_lines_to_add, mulitcore_matlab=False, queue_run=False, debug= False, custom_folders_to_compile= []):    
    ############
    # create temp matlab script file
    temp_dir = tempfile.mkdtemp( prefix=os.path.abspath("./")+"/tmp_")
    ###################
    # Import custom pathdefenitions if available
    try: shutil.copy("./pathdef.m", temp_dir+"/pathdef.m")
    except: pass
    original_script_name = os.path.abspath(original_script_name)
    with restore_curr_dir():
        os.chdir(temp_dir)
        #print os.getcwd()
        add_path_track, known_functions = find_all_scripts_paths(original_script_name, [x.strip("addpath('").strip("')") for x in list_of_lines_to_add], set([original_script_name]))
        #add_path_track, known_functions = find_all_scripts_paths(original_script_name, [], set([original_script_name]))
        #print "\n\n",known_functions
        #sys.exit(1)
        for each_function in known_functions: 
            copyedit_script_for_compiling(each_function)
        fh_temp = tempfile.NamedTemporaryFile("w", prefix=os.path.abspath("./")+"/tmp_", suffix=".m", delete=False)
        #list_of_lines_to_add.append("cd('%s')" % os.path.split(original_script_name)[0])
        list_of_lines_to_add.append("addpath('/net/isi-backup/restricted/face/matlab_mydepfun/')")
        list_of_lines_to_add.append("file_list = mydepfun('%s', true)" % os.path.split(original_script_name)[1])
        #list_of_lines_to_add.append("cd('%s')" % temp_dir)        
        ENUMERATE_TOOLBOXES = [
                             "[temporary_files_variable, toolbox_folders] = dependencies.toolboxDependencyAnalysis({%s})" % ", ".join(["'" + os.path.split(x)[-1][:-2] + "'" for x in known_functions if x[-2:]==".m"]),
                             "mytoolboxList = cell(1,numel(toolbox_folders)*2);",
                             "cmp = 0;\n",
                             "for i=1:numel(toolbox_folders)",
                             "cmp = cmp +1;",
                             "if strcmp('general', toolbox_folders{i})",
                             "if numel(toolbox_folders) == 1",
                             "mytoolboxList = {'-p','matlab'};",
                             "end",
                             "else",
                             "mytoolboxList{cmp} = '-p';",
                             "cmp = cmp +1;",
                             "mytoolboxList{cmp} = toolbox_folders{i};",
                             "end",
                             "end",
                             ]
        list_of_lines_to_add.append("\n".join(ENUMERATE_TOOLBOXES)+"\n")
        
        ##############################
        # Adding the possibility to compile entire folder structures into the code
        add_in_folders_for_compile = [
                                      "".join(["custom_folders_to_compile = {"]+ ["'"+x+"'," for x in custom_folders_to_compile] +["};"]),
                                      "compile_folders = cell(1,numel(custom_folders_to_compile)*2);",
                                      "cmp = 0;",
                                      "for i=1:numel(custom_folders_to_compile)",
                                      "cmp = cmp +1;,",
                                      "compile_folders{cmp} = '-a';",
                                      "cmp = cmp +1;",
                                      "compile_folders{cmp} = custom_folders_to_compile{i};",
                                      "end",                                      
                                      ]
        list_of_lines_to_add.append("\n".join(add_in_folders_for_compile)+"\n")
        
        ###################
        # Major change in mcc command -N removes all knowledge of paths. NO TOOLBOXES
        ###################
        #MCC_string = "mcc( '-m', '-N', '-v', '-R', '-nosplash', '-R', '-nodisplay', '-R', '-nojvm', "
        MCC_string = "mcc( '-m', '-N', mytoolboxList{1:numel(mytoolboxList)}, compile_folders{1:numel(compile_folders)},'-v', '-R', '-nosplash', '-R', '-nodisplay', '-R', '-nojvm', " 
        if not mulitcore_matlab: MCC_string = MCC_string + "'-R', '-singleCompThread', "
        MCC_string = MCC_string + "'%s', file_list{1:numel(file_list)-1})" % os.path.split(original_script_name)[1]
        list_of_lines_to_add.append(MCC_string)
        list_of_lines_to_add.append("exit")
        fh_temp.write(";\n".join(list_of_lines_to_add)+";\n")
        temp_name = fh_temp.name
        fh_temp.close()
        #if debug:
        #    print "\n\n\n\n\n", temp_name, "\n\n\n\n\n"
        #    sys.exit(1)
        ############
        # prepare run_cmd
        fgu217_queue = 'nice -19 qrsh -cwd -q fgu217.q -v BASH_ENV="~/.bashrc" -now n'
        matlab_run_cmd = '/net/isi-software/tools/matlab2011b/bin/matlab -nosplash -nodisplay' # -nojvm'
        single_core = '-singleCompThread'
        curr_script_to_run = '-r "%s; exit"' % (os.path.split(fh_temp.name)[1][:-2])
        curr_run_str_list = []
        if queue_run: curr_run_str_list.append(fgu217_queue) 
        curr_run_str_list.append(matlab_run_cmd)
        if not mulitcore_matlab: curr_run_str_list.append(single_core)
        curr_run_str_list.append(curr_script_to_run)
        
        curr_run_cmd = " ".join(curr_run_str_list)
        ############
        # run the script
        #print curr_run_cmd
        #sys.exit(1)
        run_cmd(curr_run_cmd, "running matlab scripts")
        #
        if debug:
            print "\n\n\n\n\n", "./"+os.path.split(original_script_name)[1][:-len(".m")] 
            print original_script_name[:-len(".m")]
            print "\n\n",
            print "./run_"+os.path.split(original_script_name)[1][:-len(".m")]+".sh"
            print os.path.split(original_script_name)[0]+"/run_"+os.path.split(original_script_name)[1][:-len(".m")]+".sh"
            print "\n\n\n\n\n"
            sys.exit(1)
        #sys.exit(1)
        os.rename("./"+os.path.split(original_script_name)[1][:-len(".m")], original_script_name[:-len(".m")])
        os.rename("./run_"+os.path.split(original_script_name)[1][:-len(".m")]+".sh", os.path.split(original_script_name)[0]+"/run_"+os.path.split(original_script_name)[1][:-len(".m")]+".sh")
        ############
        # cleanup
        os.unlink(temp_name)
        os.unlink("./mccExcludedFiles.log")
        os.unlink("./readme.txt")
        for each_function in known_functions:
            #print "./"+os.path.split(each_function)[1]
            try: os.unlink("./"+os.path.split(each_function)[1])
            except: pass
        try: os.unlink("./pathdef.m")
        except:pass
    os.rmdir(temp_dir)

def copyedit_script_for_compiling(original_script_name):
    script_fh_in = open(original_script_name, "r")
    try: assert not os.path.exists(os.path.split(original_script_name)[1])
    except:
        print "exists already!\t\t",original_script_name
        #sys.exit(1)
    script_fh_out = open(os.path.split(original_script_name)[1], "w")
    
    nested_in_is_deployed = False
    for curr_line in script_fh_in:
        if not re.search("(cd\()|(isdeployed)|(addpath\()", curr_line) and not nested_in_is_deployed:#|(load\()
            script_fh_out.write(curr_line)
            #print "norm line\t\t", curr_line
            continue
        if re.search("(isdeployed)", curr_line):
            nested_in_is_deployed = True
            script_fh_out.write(curr_line)
            #print "is dep line\t\t", curr_line
            continue
        if nested_in_is_deployed:
            #print "dep line\t\t", curr_line
            script_fh_out.write(curr_line)
            if re.search("(end)", curr_line):
                nested_in_is_deployed = False
            continue
        if re.search("(cd\()|(addpath\()", curr_line):
            #print "wrap up line\t\t", curr_line
            script_fh_out.write("if isdeployed\nelse\n")
            script_fh_out.write(curr_line)
            script_fh_out.write("end\n")
            #try:curr_add_path_track.append(re.search("cd\('(.+)'\)", curr_line).group(1))
            #except:curr_add_path_track.append(re.search("addpath\('(.+)'\)", curr_line).group(1))
    script_fh_in.close()
    script_fh_out.close()

def find_all_scripts_paths(original_script_name, curr_add_path_track, currently_known_functions):
    currently_known_functions.add(os.path.abspath(original_script_name))
    script_fh_in = open(original_script_name, "r")
    for curr_line in script_fh_in:
        if re.search("(cd\()|(addpath\()", curr_line):
            try:curr_add_path_track.append(re.search("cd\('(.+)'\)", curr_line).group(1))
            except:
                try: curr_add_path_track.append(re.search("addpath\('(.+)'\)", curr_line).group(1))
                except:
                    pass
                    #print "problem has in", original_script_name
                    #sys.exit(1)
    script_fh_in.close()
    lines_to_add = ["addpath('%s')" % x for x in curr_add_path_track]
    lines_to_add.append("addpath('%s')"% os.path.split(os.path.abspath(original_script_name))[0])
    lines_to_add.append("addpath('/net/isi-backup/restricted/face/matlab_mydepfun/')")
    lines_to_add.append("mydepfun_txt('%s', true, 'temp_file_list.txt')" % os.path.split(original_script_name)[1])
    run_matlab_script(None, lines_to_add, mulitcore_matlab=False, queue_run=False, debug= False)
    new_funct_set = set([x.strip("\n") for x in open('temp_file_list.txt', "r").readlines()])
    new_funct_set = new_funct_set.difference(currently_known_functions)
    for new_func in new_funct_set:
        currently_known_functions.add(new_func)
    os.unlink('temp_file_list.txt')
    for new_func in new_funct_set:
        curr_add_path_track, currently_known_functions = find_all_scripts_paths(new_func, curr_add_path_track, currently_known_functions)
    #print curr_add_path_track
    #print currently_known_functions
    return curr_add_path_track, currently_known_functions 

##################
# old version for reference
#######
#def old_compile_matlab_script(original_script_name, list_of_lines_to_add, mulitcore_matlab=False, queue_run=False, debug= False):    
#    ############
#    # create temp matlab script file
#    temp_dir = tempfile.mkdtemp( prefix=os.path.abspath("./")+"/tmp_")
#    shutil.copy("./pathdef.m", temp_dir+"/pathdef.m")
#    with restore_curr_dir():
#        os.chdir(temp_dir)
#        fh_temp = tempfile.NamedTemporaryFile("w", prefix=os.path.abspath("./")+"/tmp_", suffix=".m", delete=False)
#        list_of_lines_to_add.append("cd('%s')" % os.path.split(original_script_name)[0])
#        list_of_lines_to_add.append("addpath('/net/isi-backup/restricted/face/matlab_mydepfun/')")
#        list_of_lines_to_add.append("file_list = mydepfun('%s', true)" % os.path.split(original_script_name)[1])
#        list_of_lines_to_add.append("cd('%s')" % temp_dir)
#        MCC_string = "mcc( '-m', '-v', '-R', '-nosplash', '-R', '-nodisplay', '-R', '-nojvm', "
#        if not mulitcore_matlab: MCC_string = MCC_string + "'-R', '-singleCompThread', "
#        MCC_string = MCC_string + "'%s', file_list{1:numel(file_list)-1})" % original_script_name
#        list_of_lines_to_add.append(MCC_string)
#        list_of_lines_to_add.append("exit")
#        fh_temp.write(";\n".join(list_of_lines_to_add)+";\n")
#        temp_name = fh_temp.name
#        fh_temp.close()
#        #if debug:
#        #    print "\n\n\n\n\n", temp_name, "\n\n\n\n\n"
#        #    sys.exit(1)
#        ############
#        # prepare run_cmd
#        fgu217_queue = 'nice -19 qrsh -cwd -q fgu217.q -v BASH_ENV="~/.bashrc" -now n'
#        matlab_run_cmd = '/net/isi-software/tools/matlab2011b/bin/matlab -nosplash -nodisplay' # -nojvm'
#        single_core = '-singleCompThread'
#        curr_script_to_run = '-r "%s; exit"' % (os.path.split(fh_temp.name)[1][:-2])
#        curr_run_str_list = []
#        if queue_run: curr_run_str_list.append(fgu217_queue) 
#        curr_run_str_list.append(matlab_run_cmd)
#        if not mulitcore_matlab: curr_run_str_list.append(single_core)
#        curr_run_str_list.append(curr_script_to_run)
#        
#        curr_run_cmd = " ".join(curr_run_str_list)
#        ############
#        # run the script
#        #print curr_run_cmd
#        #sys.exit(1)
#        run_cmd(curr_run_cmd, "running matlab scripts")
#        #
#        if debug:
#            print "\n\n\n\n\n", "./"+os.path.split(original_script_name)[1][:-len(".m")] 
#            print original_script_name[:-len(".m")]
#            print "\n\n",
#            print "./run_"+os.path.split(original_script_name)[1][:-len(".m")]+".sh"
#            print os.path.split(original_script_name)[0]+"/run_"+os.path.split(original_script_name)[1][:-len(".m")]+".sh"
#            print "\n\n\n\n\n"
#            #sys.exit(1)
#        #sys.exit(1)
#        os.rename("./"+os.path.split(original_script_name)[1][:-len(".m")], original_script_name[:-len(".m")])
#        os.rename("./run_"+os.path.split(original_script_name)[1][:-len(".m")]+".sh", os.path.split(original_script_name)[0]+"/run_"+os.path.split(original_script_name)[1][:-len(".m")]+".sh")
#        ############
#        # cleanup
#        os.unlink(temp_name)
#        os.unlink("./mccExcludedFiles.log")
#        os.unlink("./readme.txt")
#        os.unlink("./pathdef.m")
#    os.rmdir(temp_dir)


def run_matlab_script_compiled(original_script_name, list_of_variables, list_of_non_symlink_var = [], mulitcore_matlab=False, queue_run=True, cluster_run=True, debug= False, ):
    
    TEMPORARY_FOLDER_FOLDER = "temp_run_folders/"
    try: os.mkdir(TEMPORARY_FOLDER_FOLDER)
    except: assert  os.path.exists(TEMPORARY_FOLDER_FOLDER)

    ############
    # create temp matlab script file
    temp_dir = tempfile.mkdtemp( prefix=os.path.abspath("./"+TEMPORARY_FOLDER_FOLDER)+"/tmp_")
    symlink_names = []
    for curr_var in list_of_variables:
        curr_var_name, curr_var_val = curr_var.split(" = ")
        curr_var_val = curr_var_val.strip("'")
        fh_out = open(temp_dir+"/"+curr_var_name+".txt", "w")
        ######################
        #  Make symbolic links to all directories to prevent 64 char limit in matlab issue
        # IS THIS ACUTALLY AN ISSUE?
        
        curr_dir, curr_file_name = os.path.split(curr_var_val)
        curr_symlink_name = temp_dir+"/"+curr_var_name
        symlink_names.append(curr_symlink_name)
        os.symlink(os.path.split(os.path.abspath(curr_var_val))[0], curr_symlink_name)
        #
        ######################
        #print os.path.split(curr_var_val)
        fh_out.write(curr_var_name+"/"+os.path.split(curr_var_val)[1])
        #fh_out.write(os.path.abspath(curr_var_val))
        fh_out.close()
    ############
    for curr_var in list_of_non_symlink_var:
        curr_var_name, curr_var_val = curr_var.split(" = ")
        curr_var_val = curr_var_val.strip("'")
        fh_out = open(temp_dir+"/"+curr_var_name+".txt", "w")
        fh_out.write(curr_var_val)
        fh_out.close()
    ############
    # prepare run_cmd
    
    shutil.copy(os.path.split(original_script_name)[0]+"/run_"+os.path.split(original_script_name)[1][:-len(".m")]+".sh", temp_dir+"/run_"+os.path.split(original_script_name)[1][:-len(".m")]+".sh")
    shutil.copy(os.path.split(original_script_name)[0]+"/"+os.path.split(original_script_name)[1][:-len(".m")], temp_dir+"/"+os.path.split(original_script_name)[1][:-len(".m")])
    
    fgu217_queue = 'nice -19 qrsh -cwd -q fgu217.q -v BASH_ENV="~/.bashrc" -now n'
    cluster_queue = 'nice -19 qrsh -cwd -q medium_jobs.q -v BASH_ENV="~/.bashrc" -now n'
    script_to_run_cmd = temp_dir+"/run_"+os.path.split(original_script_name)[1][:-len(".m")]+".sh /net/isi-software/tools/matlab2011b/"
    curr_run_str_list = []
    if queue_run:
        if cluster_run:
            curr_run_str_list.append(cluster_queue)
        else:
            curr_run_str_list.append(fgu217_queue) 
    curr_run_str_list.append(script_to_run_cmd)
    curr_run_cmd = " ".join(curr_run_str_list)
    ############
    # run the script
    if debug:
        print curr_run_cmd
        sys.exit(1)
    with restore_curr_dir():
        os.chdir(temp_dir)
        #sys.exit(1)
        if cluster_run: time.sleep(random.randint(1,7))
        run_cmd(curr_run_cmd, "running matlab scripts")
    ############
    # cleanup
    for x_files in glob.glob(temp_dir+"/*"):
        os.unlink(x_files)
    shutil.rmtree(temp_dir)
    
