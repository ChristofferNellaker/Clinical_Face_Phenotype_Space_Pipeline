#!/usr/bin/env python
"""
  Clinical_Face_Phenotype_Space_pipeline.py
  default pipeline settings in pipeline_defaults.ini
  image directory path (points to path of where folders with images are) defined in image_folders.ini
  Copyright (c) 06/5/2014 Christoffer Nellaker
"""
PIPELINE_NAME = "Clinical_Face_Phenotype_Space_pipeline"

################################################################################
#Clinical Face Phenotype Space pipeline.
#v1.2
#
#Copyright (c) 06/5/2014 Christoffer Nellaker
#Permission is hereby granted, free of charge, to any person obtaining a copy
#of this software and associated documentation files (the "Software"), to deal
#in the Software without restriction, including without limitation the rights
#to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
##   copies of the Software, and to permit persons to whom the Software is
#furnished to do so, subject to the following conditions:
#
#The above copyright notice and this permission notice shall be included in
#all copies or substantial portions of the Software.
#THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
#FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
#THE SOFTWARE.
#-------------------------------------------------------------------



#88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888

#   options        

#88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888

from optparse import OptionParser
import sys, os
import os.path
import StringIO
import ConfigParser

# add self to search path for testing
if __name__ == '__main__':
  exe_path = os.path.split(os.path.abspath(sys.argv[0]))[0]
  sys.path.append(os.path.abspath(os.path.join(exe_path,"..", "python_modules")))
  module_name = os.path.split(sys.argv[0])[1]
  module_name = os.path.splitext(module_name)[0];
else:
  module_name = __name__

####    Import INI file    ####
default_configs = ConfigParser.RawConfigParser()
default_configs.read("./pipeline_defaults.ini")

image_folders_list = []
for curr_line in open("./image_folders.ini", "r"):
    if curr_line[0] in set(["#", " ", "\n"]):continue
    image_folders_list.append(curr_line.strip("\n"))


parser = OptionParser(version="%prog 1.0", usage = "\n\n    %progs [options]")
parser.add_option("--fr_matlab_scripts_dir", dest="fr_matlab_scripts_dir",
                default= default_configs.get("Face", "fr_matlab_scripts_dir"),
                metavar="directory path",
                help="Path of matlab scripts. "
                    "Defaults to reading from pipeline_defaults.ini.")
parser.add_option("--fr_images_dirs", dest="fr_images_dirs",
                action="append",
                #default= default_configs.get("Face", "fr_images_dirs"),
                default = image_folders_list,
                metavar="directory paths",
                #type="string",
                help="Path of image containing folders. "
                    "Defaults to reading from image_folders.ini.")
parser.add_option("--skin_mat", dest="skin_mat",
                default= default_configs.get("Face", "skin_mat"),
                metavar="skin type matlab file",
                type="string",
                help="Path of to model of skin appearance. "
                    "Defaults to reading from pipeline_defaults.ini.")
parser.add_option("--dif_data_mat", dest="dif_data_mat",
                default= default_configs.get("Face", "dif_data_mat"),
                metavar="dif_data_mat",
                type="string",
                help="Path of to dif model. "
                    "Defaults to reading from pipeline_defaults.ini.")
parser.add_option("--cCPR_models", dest="cCPR_models",
                default= default_configs.get("Face", "cCPR_models"),
                metavar="matlab cCPR_models file",
                type="string",
                help="Path to CPR models file. "
                    "Defaults to reading from pipeline_defaults.ini.")
parser.add_option("--VJ_root_path", dest="VJ_root_path",
                default= default_configs.get("Face", "VJ_root_path"),
                metavar="VJ_root_path points to VJ root",
                type="string",
                help="Path of image containing folders. "
                    "Defaults to reading from pipeline_defaults.ini.")
parser.add_option("--Face_feat_model", dest="Face_feat_model",
                default= default_configs.get("Face", "Face_feat_model"),
                metavar="Face_feat_model points to facial feature model",
                type="string",
                help="Path of image containing folders. "
                    "Defaults to reading from pipeline_defaults.ini.")
parser.add_option("--CoE_model", dest="CoE_model",
                default= default_configs.get("Face", "CoE_model"),
                metavar="CoE_model points to the belhuemur inspired CoE model",
                type="string",
                help="Path to Conensus of exemplars models. "
                    "Defaults to reading from pipeline_defaults.ini.")
parser.add_option("--Belh_parts_models", dest="Belh_parts_models",
                default= default_configs.get("Face", "Belh_parts_models"),
                metavar="CoE_model points to the belhuemur inspired Belh_parts_models",
                type="string",
                help="Path to parts models. "
                    "Defaults to reading from pipeline_defaults.ini.")
parser.add_option("--Belh_P_delta", dest="Belh_P_delta",
                default= default_configs.get("Face", "Belh_P_delta"),
                metavar="CoE_model points to the belhuemur inspired Belh_P_delta",
                type="string",
                help="Path of image containing folders. "
                    "Defaults to reading from pipeline_defaults.ini.")
parser.add_option("--Belh_train_class", dest="Belh_train_class",
                default= default_configs.get("Face", "Belh_train_class"),
                metavar="Belh_train_class points to the Belhuemur_trained_class used for syndrome trained belhumeur",
                type="string",
                help="Path of image containing folders. "
                    "Defaults to reading from pipeline_defaults.ini.")
parser.add_option("--database_file", dest="database_file",
                default= default_configs.get("Face", "database_file"),
                metavar="Path to the sqlite3 database for storing all meta data and feature points",
                type="string",
                help="Path of image containing folders. "
                    "Defaults to reading from pipeline_defaults.ini.")
parser.add_option("--AAM_models", dest="AAM_models",
                default= default_configs.get("Face", "AAM_models"),
                metavar="Path to the AAM models for AAM script",
                type="string",
                help="Path of image containing folders. "
                    "Defaults to reading from pipeline_defaults.ini.")
parser.add_option("--AAM_shape_model", dest="AAM_shape_model",
                default= default_configs.get("Face", "AAM_shape_model"),
                metavar="Path to the AAM models for AAM script",
                type="string",
                help="Path of image containing folders. "
                    "Defaults to reading from pipeline_defaults.ini.")
parser.add_option("--FS_model", dest="FS_model",
                default= default_configs.get("Face", "FS_model"),
                metavar="Path to the models for FaceSpace deformation",
                type="string",
                help="Path of image containing folders. "
                    "Defaults to reading from pipeline_defaults.ini.")



#
#   general options: verbosity / logging
#
parser.add_option("-v", "--verbose", dest = "verbose",
                action="count", default=0,
                help="Print more verbose messages for each additional verbose level.")
parser.add_option("-L", "--log_file", dest="log_file",
                metavar="FILE",
                type="string",
                help="Name and path of log file")
parser.add_option("--skip_parameter_logging", dest="skip_parameter_logging",
                  action="store_true", default=False,
                  help="Do not print program parameters to log.")
parser.add_option("--debug", dest="debug",
                  action="store_true", default=False,
                  help="Set default program parameters in debugging mode.")
parser.add_option("-n", "--no_run_just_print", dest="no_run_just_print",
                  action="store_true", default=False,
                  help="Set default program parameters in debugging mode.")
parser.add_option("-f", "--force", dest="force",
                  action="store_true", default=False,
                  help="Set default program parameters in debugging mode.")
parser.add_option("-g", "--graph_it", dest="graph_it",
                  action="store_true", default=False,
                  help="Print graph of pipeline.")
parser.add_option("--restat_images", dest="restat_images",
                  action="store_true", default=False,
                  help="Re-walk the directory structure to find all images. Takes a very long time, only do it when there are new images to check")


# get help string
f =StringIO.StringIO()
parser.print_help(f)
helpstr = f.getvalue()
(options, remaining_args) = parser.parse_args()

if options.debug:
  options.log_file = os.path.join("programme_mit_license.log")

# mandatory options
from options import check_mandatory_options
mandatory_options = []
check_mandatory_options (options, mandatory_options, helpstr)

#88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888

#   imports        

#88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888

import StringIO
import re
import operator
from ruffus import *
import time
import glob
from sqlite_scheduler import sqlite_scheduler
from path_to_meta_data_parser import path_to_meta_data_parser

from collections import defaultdict
import logging
from lg_program_logging import setup_std_logging #Use a logger of choice here
from options import get_option_strings
from run_cmd import run_cmd
import tempfile
from run_matlab_script import run_matlab_script, run_matlab_script_compiled, compile_matlab_script

import cPickle
import sqlite3

#88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888

#   Constants        

#88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888


SHORT_LINK_NAME = "./scripts_dir"
DEBUGGING_MODE = False
QUEUE_RUN_MODE = False
CLUSTER_RUN_MODE = False

MATLAB_MULTICORE_MODE = False
MULTIPROCESSES = 5      
DISPLAY_FOLDER = "display/"
DEID_FOLDER = "de_identified/"
PIPE_OUT_FOLDER = "facespace_data/"
TEMPORARY_FOLDER_FOLDER = "temp_run_folders/"


#88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888

#   Functions        

#88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888


def get_global_list_of_images(list_of_folders, exclusion_list_file = None):
    image_list = []
    if options.restat_images or not os.path.exists(options.database_file):
        exclusion_set = set()
        try:
            for curr_line in open(exclusion_list_file,"r"):
                exclusion_set.add(curr_line.strip("\n"))
        except: pass
        for curr_fold in list_of_folders:
            for root, folders, files in os.walk(curr_fold):
                if re.match(".*facespace_data.*", root): continue
                for file in files:
                    if re.match(".*%s.*|.*%s.*|.*%s.|.*CLINICIAN_CHECK.*|.*DISPLAY.*|.*WWW_OLD_DATA.*|.*TEMPFOLDER.*|.*SCRIPTS.*|.*ADD_MAT_OLD.*" % (DISPLAY_FOLDER[:-1], DEID_FOLDER[:-1], PIPE_OUT_FOLDER[:-1]), root): continue
                    if root+"/"+file not in exclusion_set:# and re.match("(.+/)(.+)\.([Gg][Ii][Ff]|[jJ][pP][gG]|[Jj][Pp][Ee][Gg]|[Bb][Mm][pP]|[Tt][Ii][fF][Ff]|[Pp][Nn][Gg])\Z"):
                        image_list.append(root+"/"+file)
                        #print root+"/"+file
                    #image_list = image_list + [x for x in glob.glob(curr_fold+ "/*/*") if x not in exclusion_set]
            #image_list = image_list + [x for x in glob.glob(curr_fold+ "/*/*") if x not in exclusion_set and os.path.split(x)[0].split("/")[-1] in set(["controles",])] #, "apertJPG", "downJPG", "williamsJPG" EVIL HACK and os.path.split(x)[0].split("/")[-1] == "controles"
    else:
        #print "Trying to load stored image list\n"
        db_connection = sqlite3.connect(options.database_file)
        db_pointer = db_connection.cursor()
        image_list = [str(image_path)+str(image_name) for image_path,image_name in db_pointer.execute("select image_path, image_name from processing") if re.match("|".join([x+".*" for x in list_of_folders]), image_path)]
        for image_name in image_list:
            
            if re.match(".*facespace_data.*", image_name):
                print image_name
                #db_pointer.execute("DELETE from processing where image_path = '%s/' and image_name = '%s';" % os.path.split(image_name))
                #db_connection.commit()
        #    print image_path
        #    image_list.append(image_path+"/"+image_name)
        db_connection.close()
    #for x in image_list: print x
    return image_list

def convert_original_to_jpeg_job_list(input_name_list):
    out_jobs_list = []
    for each_input_name in input_name_list:
        if each_input_name.split(".")[-1] not in set(["gif","jpg", "jpeg", "bmp", "tiff","png","gif","JPG", "JPEG", "BMP", "TIFF","PNG"]): continue 
        each_output_name = os.path.split(each_input_name)[0] +"/"+PIPE_OUT_FOLDER+ "_".join(os.path.split(each_input_name)[-1].split(".")) + ".jpg"
        out_jobs_list.append([each_input_name, each_output_name])
    #print out_jobs_list[0]
    #sys.exit(1)
    return out_jobs_list 

def convert_original_to_meta_job_list(input_name_list):
    out_jobs_list = []
    for each_input_name in input_name_list:
        if each_input_name.split(".")[-1] not in set(["gif","jpg", "jpeg", "bmp", "tiff","png","gif","JPG", "JPEG", "BMP", "TIFF","PNG"]): continue 
        each_output_name = os.path.split(each_input_name)[0] +"/"+PIPE_OUT_FOLDER+ "_".join(os.path.split(each_input_name)[-1].split(".")) + ".meta"
        out_jobs_list.append([each_input_name, each_output_name])
    #print out_jobs_list[0]
    #sys.exit(1)
    return out_jobs_list 

@jobs_limit(1)
@transform(glob.glob(options.fr_matlab_scripts_dir + "dbp_*_X.m"), suffix(".m"), "")#pipe_*_X.m"), suffix(".m"), "")
def compile_matlab_code(input,output):
    lines_to_add = [
                    "addpath('%s')" % options.fr_matlab_scripts_dir,
                    ]
    
    custom_folders_to_compile = [
                                 './matlab-sqlite3-driver/', #configure this to wherever you installed this driver.
                                 ]
    compile_matlab_script(options.fr_matlab_scripts_dir +os.path.split(input)[1], lines_to_add, mulitcore_matlab=False, queue_run=False, debug = False, custom_folders_to_compile = custom_folders_to_compile)

@follows(compile_matlab_code)
@files([], options.database_file)#"/net/isi-backup/restricted/face/DB_syndrome")
def create_database(input, output):
    lines_to_add = [
                    "var_database = %s*" % options.database_file,
                    ]
    run_matlab_script_compiled(options.fr_matlab_scripts_dir +"dbp_0_create_DB_X.m", lines_to_add, mulitcore_matlab=MATLAB_MULTICORE_MODE, queue_run=QUEUE_RUN_MODE, cluster_run=CLUSTER_RUN_MODE, debug = DEBUGGING_MODE)
    hold_for_output(output)
    

@follows(compile_matlab_code)
@transform(get_global_list_of_images(options.fr_images_dirs), regex(r"(.+/)(.+)\.([Gg][Ii][Ff]|[jJ][pP][gG]|[Jj][Pp][Ee][Gg]|[Bb][Mm][pP]|[Tt][Ii][fF][Ff]|[Pp][Nn][Gg])\Z"), inputs(r"\1\2.\3"), r"\1%s\2_\3.jpg" % PIPE_OUT_FOLDER)
def convert_original_to_jpeg(input, output):
    
    try: os.mkdir(os.path.split(output)[0])
    except: pass
    if os.path.exists(output): os.unlink(output)
    lines_to_add = [
                    "varin_1 = '%s'" % input,
                    "var_database = %s*" % options.database_file,
                    "varin_image_path = %s*" % input,
                    "varout_image_path = %s*" % output,
                    ]
    run_matlab_script_compiled(options.fr_matlab_scripts_dir +"dbp_0_create_jpeg_X.m", lines_to_add, mulitcore_matlab=MATLAB_MULTICORE_MODE, queue_run=QUEUE_RUN_MODE, cluster_run=CLUSTER_RUN_MODE, debug = DEBUGGING_MODE)
    hold_for_output(output)


@follows(compile_matlab_code, create_database)
@transform(convert_original_to_jpeg, suffix("jpg"), "also_meta")
def create_meta_data_record(input, output):
    
    try: os.mkdir(os.path.split(output)[0])
    except: pass
    try: os.mkdir(TEMPORARY_FOLDER_FOLDER)
    except: pass
    if os.path.exists(output): os.unlink(output)

    ################################################################
    # Parse meta data and update person record
    #############
    db_connection = sqlite3.connect(options.database_file)
    db_pointer = db_connection.cursor()
    meta_dict = path_to_meta_data_parser(input)
    
  
    
    with tempfile.NamedTemporaryFile(suffix = ".request", dir = TEMPORARY_FOLDER_FOLDER) as temp_request_file:
        while True:
            if not os.path.exists(options.database_file+".queue"): time.sleep(0.5)
            else: 
                #print "checking...", open(options.database_file+".queue","r").readline().strip("\n"), os.path.split(temp_request_file.name),open(options.database_file+".queue","r").readline().strip("\n") == os.path.split(temp_request_file.name)[1] 
                if open(options.database_file+".queue","r").readline().strip("\n") == os.path.split(temp_request_file.name)[1]:
                    #print "accepted!" 
                    break
        ################
        # Must be with db locking else duplicated meta records appear
        while True:
        #try: 
            record = [x for x in db_pointer.execute("select * from meta where patient_id = ?", (meta_dict["patient_id"],))]
            break
        #except: print "re-ping sqlite database"
    
        sqlite_cmd = "nope!"
        if record:
            sqlite_cmd = "".join(["UPDATE meta SET"] + [" "+str(x)+' = "'+str(y)+'",' for x,y in meta_dict.iteritems()])
            sqlite_cmd = sqlite_cmd[:-1]+'where patient_id = "%s"' % str(meta_dict["patient_id"])
        else:
            sqlite_cmd = "INSERT INTO meta (%s) VALUES (%s)" % (",".join([str(x) for x in meta_dict.keys()]) , ",".join(['"'+str(x)+'"' for x in meta_dict.values()]))
        try: db_pointer.execute(sqlite_cmd)
        except:
            print "failed", sqlite_cmd
            db_pointer.execute(sqlite_cmd)
            sys.exit(1)
        db_connection.commit()
        db_connection.close()
    
    fh_out = open(output, "w")
    fh_out.close()
        
    
    
    ################################################################


@follows(compile_matlab_code, create_database)
@transform(convert_original_to_jpeg, suffix("jpg"), "meta")
def create_processing_data_record(input, output):
    
    original_image_name = "".join(input.split(PIPE_OUT_FOLDER))[:-4]
    original_image_name_suffix = original_image_name.split("_")[-1]
    original_image_name = original_image_name[:-len(original_image_name_suffix)-1]+"."+original_image_name_suffix
    
    
    #####
    try: os.mkdir(os.path.split(output)[0])
    except: pass
    if os.path.exists(output): os.unlink(output)
    
    lines_to_add = [
                    "varin_1 = '%s'" % original_image_name,
                    "var_database = %s*" % options.database_file,
                    "varout_1 = %s*" % output,
                    ]
    list_of_non_symlink_var = [
                               "varin_image_path = %s*" % os.path.abspath(input),
                               "varout_image_path = %s*" % os.path.abspath(output[:-4]+"jpg"),
                               ]
    run_matlab_script_compiled(options.fr_matlab_scripts_dir +"dbp_1_store_image_X.m", lines_to_add,list_of_non_symlink_var=list_of_non_symlink_var, mulitcore_matlab=MATLAB_MULTICORE_MODE, queue_run=QUEUE_RUN_MODE, cluster_run=CLUSTER_RUN_MODE, debug = DEBUGGING_MODE)
    #run_matlab_script_compiled(options.fr_matlab_scripts_dir +"pipe_0_png2jpg_X.m", lines_to_add, mulitcore_matlab=MATLAB_MULTICORE_MODE, queue_run=QUEUE_RUN_MODE, cluster_run=CLUSTER_RUN_MODE, debug = DEBUGGING_MODE)
    hold_for_output(output)

@follows(convert_original_to_jpeg, create_processing_data_record)#, create_meta_data_record)
@transform(convert_original_to_jpeg, suffix(".jpg"), ".impfland")    
def run_improved_landmark_detection(input, output):
    
    if os.path.exists(output): os.unlink(output)
    lines_to_add = [
                    "varin_1 = '%s'" % input,
                    "varin_2 = '%s'" % options.VJ_root_path,
                    "varin_3 = '%s'" % options.Face_feat_model,
                    "var_database = %s*" % options.database_file,
                    "varout_1 = '%s*" % output,
                    ]
    list_of_non_symlink_var = [
                               "varin_image_path = %s*" % os.path.abspath(input),
                               ]
    run_matlab_script_compiled(options.fr_matlab_scripts_dir +"dbp_2_find_facial_lands_X.m", lines_to_add, list_of_non_symlink_var=list_of_non_symlink_var, mulitcore_matlab=MATLAB_MULTICORE_MODE, queue_run=QUEUE_RUN_MODE, cluster_run=CLUSTER_RUN_MODE, debug = DEBUGGING_MODE)
    
    hold_for_output(output)


@follows(run_improved_landmark_detection, convert_original_to_jpeg)
@collate([run_improved_landmark_detection], regex(r"(.+/)(.+)\.impfland"), inputs([r"\1\2.impfland", r"\1\2.jpg"]), r"\1\2.impaam")
def run_AAM_fitting(input, output):

    if os.path.exists(output): os.unlink(output)
    lines_to_add = [
                    "varin_1 = '%s'" % input[0][1],
                    "varin_2 = '%s'" % input[0][0],
                    #"varin_image_path = '%s*" % input[0][1],
                    "varin_3 = %s*" % options.AAM_models,
                    "varout_1 = '%s*" % output,
                    "var_database = %s*" % options.database_file,
                    ]
    list_of_non_symlink_var = [
                               "varin_image_path = %s*" % os.path.abspath(input[0][1]),
                               ]
    run_matlab_script_compiled(options.fr_matlab_scripts_dir +"dbp_3_AAM_X.m", lines_to_add, list_of_non_symlink_var=list_of_non_symlink_var, mulitcore_matlab=MATLAB_MULTICORE_MODE, queue_run=QUEUE_RUN_MODE, cluster_run=CLUSTER_RUN_MODE, debug = DEBUGGING_MODE)
    #run_matlab_script_compiled(options.fr_matlab_scripts_dir +"pipe_3_AAM_X.m", lines_to_add, mulitcore_matlab=MATLAB_MULTICORE_MODE, queue_run=QUEUE_RUN_MODE, cluster_run=CLUSTER_RUN_MODE, debug = DEBUGGING_MODE)
    #except:
    #    open(output, "w").close()
    hold_for_output(output)
    
@follows(run_improved_landmark_detection, convert_original_to_jpeg)
@collate([run_improved_landmark_detection], regex(r"(.+/)(.+)\.impfland"), inputs([r"\1\2.jpg", r"\1\2.impfland"]), [r"\1\2.bfland", r"\1"+DISPLAY_FOLDER +r"\2.disp_behumeur.jpg"])
def run_belhumeur_fitting(input, output):

    if os.path.exists(output[0]): os.unlink(output[0])
    try: os.mkdir(os.path.split(output[1])[0])
    except: assert  os.path.exists(os.path.split(output[1])[0])
    lines_to_add = [
                    "varin_1 = '%s'" % input[0][0],
                    "varin_2 = '%s'" % input[0][1],
                    "varin_3 = '%s'" % options.CoE_model,
                    "varin_4 = '%s'" % options.Belh_parts_models,
                    "varin_5 = '%s'" % options.Belh_P_delta,
                    #"varin_image_path = '%s*" % input[0][0],
                    "varout_1 = '%s*" % output[0],
                    "varout_2 = '%s*" % output[1],
                    "var_database = %s*" % options.database_file,
                    ]
    list_of_non_symlink_var = [
                               "varin_image_path = %s*" % os.path.abspath(input[0][0]),
                               ]
    run_matlab_script_compiled(options.fr_matlab_scripts_dir +"dbp_3_Belhumeur_X.m", lines_to_add, list_of_non_symlink_var=list_of_non_symlink_var, mulitcore_matlab=MATLAB_MULTICORE_MODE, queue_run=QUEUE_RUN_MODE, cluster_run=CLUSTER_RUN_MODE, debug = DEBUGGING_MODE)
    #run_matlab_script_compiled(options.fr_matlab_scripts_dir +"pipe_3_belhumeur_X.m", lines_to_add, mulitcore_matlab=MATLAB_MULTICORE_MODE, queue_run=QUEUE_RUN_MODE, cluster_run=CLUSTER_RUN_MODE, debug = DEBUGGING_MODE)
    #except:
    #    open(output, "w").close()
    hold_for_output(output[0])


@follows(run_AAM_fitting, run_belhumeur_fitting)
@collate([run_AAM_fitting], regex(r"(.+/)(.+)\.impaam"), inputs([r"\1\2.jpg", r"\1\2.impaam", r"\1\2.bfland"]), [r"\1\2.feats"])
def run_feature_extraction(input, output):
    #sys.exit(1)
    if os.path.exists(output[0]): os.unlink(output[0])
    try: os.mkdir(os.path.split(output[0])[0])
    except: assert  os.path.exists(os.path.split(output[0])[0])
    lines_to_add = [
                    "varin_1 = %s*" % input[0][0],
                    "varin_2 = %s*" % options.AAM_shape_model,
                    "varin_3 = '%s'" % options.Face_feat_model,
                    "varout_1 = '%s*" % output[0],
                    "var_database = %s*" % options.database_file,
                    ]
    list_of_non_symlink_var = [
                               "varin_image_path = %s*" % os.path.abspath(input[0][0]),
                               ]
    run_matlab_script_compiled(options.fr_matlab_scripts_dir +"dbp_4_feature_vectors_X.m", lines_to_add, list_of_non_symlink_var=list_of_non_symlink_var, mulitcore_matlab=MATLAB_MULTICORE_MODE, queue_run=QUEUE_RUN_MODE, cluster_run=CLUSTER_RUN_MODE, debug = DEBUGGING_MODE)
    hold_for_output(output[0])

@follows(run_feature_extraction)
@collate([run_feature_extraction], regex(r"(.+/)(.+)\.feats"), inputs([r"\1\2.jpg", r"\1\2.feats"]), [r"\1\2.FS_feats"])
def run_FS_feature_transform(input, output):
    #sys.exit(1)
    if os.path.exists(output[0]): os.unlink(output[0])
    try: os.mkdir(os.path.split(output[0])[0])
    except: assert  os.path.exists(os.path.split(output[0])[0])
    lines_to_add = [
                    "varin_1 = %s*" % input[0][0],
                    "varin_2 = %s*" % options.FS_model,
                    #"varin_3 = '%s'" % options.Face_feat_model,
                    "varout_1 = '%s*" % output[0],
                    "var_database = %s*" % options.database_file,
                    ]
    list_of_non_symlink_var = [
                               "varin_image_path = %s*" % os.path.abspath(input[0][0]),
                               ]
    run_matlab_script_compiled(options.fr_matlab_scripts_dir +"dbp_5_lmnn_vectors_X.m", lines_to_add, list_of_non_symlink_var=list_of_non_symlink_var, mulitcore_matlab=MATLAB_MULTICORE_MODE, queue_run=QUEUE_RUN_MODE, cluster_run=CLUSTER_RUN_MODE, debug = DEBUGGING_MODE)
    hold_for_output(output[0])

@jobs_limit(10) #no point running more in parallel, fast process- limitation is on DB access
@follows(create_meta_data_record, run_FS_feature_transform)
@transform(create_meta_data_record, suffix("also_meta"), "linked_meta")
def link_meta_data_record(input, output):
    #sys.exit(1)
    try: os.mkdir(os.path.split(output)[0])
    except: pass
    try: os.mkdir(TEMPORARY_FOLDER_FOLDER)
    except: pass
    if os.path.exists(output): os.unlink(output)
    
    
    ################################################################
    # Parse meta data and update person record
    #############
    db_connection = sqlite3.connect(options.database_file)
    db_pointer = db_connection.cursor()
    image_path_name = input[:-len("also_meta")]+"jpg"
    meta_dict = path_to_meta_data_parser(image_path_name)
    #print image_path_name, "\n", meta_dict, "\n", input, "\n\n\n" 
    
    #print meta_dict["patient_id"]
    while True:
        #try: 
        meta_id_record = [str(x[0]) for x in db_pointer.execute("select id from meta where patient_id = ?", (meta_dict["patient_id"],))]
        try: assert len(meta_id_record) == 1
        except:
            print meta_id_record, meta_dict["patient_id"]
            sys.exit("meta_id_record larger than 1")
        #print record
        break
        #except: print "re-ping sqlite database"
    
    
    with tempfile.NamedTemporaryFile(suffix = ".request", dir = TEMPORARY_FOLDER_FOLDER) as temp_request_file:
        while True:
            if not os.path.exists(options.database_file+".queue"): time.sleep(0.5)
            else: 
                #print "checking...", open(options.database_file+".queue","r").readline().strip("\n"), os.path.split(temp_request_file.name),open(options.database_file+".queue","r").readline().strip("\n") == os.path.split(temp_request_file.name)[1] 
                if open(options.database_file+".queue","r").readline().strip("\n") == os.path.split(temp_request_file.name)[1]:
                    #print "accepted!" 
                    break
        try: db_pointer.execute("UPDATE processing SET meta_id = ? WHERE image_path_name = ?", (meta_id_record[0], image_path_name))
        except:
            print "failed", "UPDATE processing SET meta_id = ? WHERE image_path_name = ?", meta_id_record[0], image_path_name
            db_pointer.execute("UPDATE processing SET meta_id = ? WHERE image_path_name = ?", (meta_id_record[0], image_path_name))
            sys.exit(1)
        db_connection.commit()
        db_connection.close()
    
    fh_out = open(output, "w")
    fh_out.close()
    #with sqlite_scheduler(options.database_file, "temp_run_folders/", ".request", ".queue") as deamon_running:


@jobs_limit(1)
#@follows(link_meta_data_record)
@transform([x for y in options.fr_images_dirs for x in glob.glob(y+"/*_blacklist.txt")]+[x for y in options.fr_images_dirs for x in glob.glob(y+"/*_failedlist.txt")], suffix("txt"), "dbsentinel")
def flag_down_clinical_and_gross_missannotations(input, output):
    #################
    # Used as a posthoc removal of images that were determined to have the incorrect diagnosis
    # redundant in later versions of this code

    fh_in = open(input, "r")
    for curr_line in fh_in:
        curr_line = curr_line.strip("*\n")
        if curr_line == [] or curr_line == "empty": 
            continue
        curr_dir, curr_sub_dir = os.path.split(os.path.abspath(input))
        curr_subdir = "_".join(curr_sub_dir.split("_")[:-1])
        curr_dir = curr_dir+"/"+curr_subdir+"/facespace_data/"
        image_path_name  = curr_dir + curr_line
        with tempfile.NamedTemporaryFile(suffix = ".request", dir = TEMPORARY_FOLDER_FOLDER) as temp_request_file:
            while True:
                if not os.path.exists(options.database_file+".queue"): time.sleep(0.5)
                else: 
                    #print "checking...", open(options.database_file+".queue","r").readline().strip("\n"), os.path.split(temp_request_file.name),open(options.database_file+".queue","r").readline().strip("\n") == os.path.split(temp_request_file.name)[1] 
                    if open(options.database_file+".queue","r").readline().strip("\n") == os.path.split(temp_request_file.name)[1]:
                        #print "accepted!" 
                        break
            #-------------- Update database
            db_connection = sqlite3.connect(options.database_file)
            db_pointer = db_connection.cursor()
            try: db_pointer.execute("UPDATE processing SET boolean_success = 0 WHERE image_path_name = ?", (image_path_name,))
            except:
                print "failed", "UPDATE processing SET boolean_success = 0 WHERE image_path_name = ?", image_path_name
                #db_pointer.execute("UPDATE processing SET meta_id = ? WHERE image_path_name = ?", (meta_id_record[0], image_path_name))
                sys.exit(1)
            db_connection.commit()
            db_connection.close()
    fh_in.close()
    
    fh_out = open(output, "w")
    fh_out.close()
        

@follows(link_meta_data_record,run_FS_feature_transform, flag_down_clinical_and_gross_missannotations)
@merge([link_meta_data_record,run_FS_feature_transform], ["output_Diag_P0P1_acc.tab"])
def run_global_p0p1_metrics(input, output):
    if os.path.exists(output[0]): os.unlink(output[0])
    lines_to_add = [
                    "varout_1 = '%s*" % output[0],
                    "var_database = %s*" % options.database_file,
                    ]
    run_matlab_script_compiled(options.fr_matlab_scripts_dir +"dbp_6_p0p1_X.m", lines_to_add, mulitcore_matlab=MATLAB_MULTICORE_MODE, queue_run=QUEUE_RUN_MODE, cluster_run=CLUSTER_RUN_MODE, debug = DEBUGGING_MODE)
    hold_for_output(output[0])

@follows(link_meta_data_record,run_FS_feature_transform, flag_down_clinical_and_gross_missannotations)
@merge([link_meta_data_record,run_FS_feature_transform], ["output_CIF_acc.tab"])
def run_global_CIF_metrics(input, output):
    if os.path.exists(output[0]): os.unlink(output[0])
    lines_to_add = [
                    "varout_1 = '%s*" % output[0],
                    "var_database = %s*" % options.database_file,
                    ]
    run_matlab_script_compiled(options.fr_matlab_scripts_dir +"dbp_6_CIF_stats_X.m", lines_to_add, mulitcore_matlab=MATLAB_MULTICORE_MODE, queue_run=QUEUE_RUN_MODE, cluster_run=CLUSTER_RUN_MODE, debug = DEBUGGING_MODE)
    hold_for_output(output[0])

#@follows(run_AAM_fitting, run_belhumeur_fitting)
@follows(run_global_p0p1_metrics, run_global_CIF_metrics)
@files([], "misc.placeholder.sentinel")
def run_display(input, output):
    pass

    
def hold_for_output(file_id):
    print "Awaiting output:", file_id, " >",
    counter = 1
    while not os.path.exists(file_id):
        time.sleep(1)
        counter += 1
        print ".",
    print "< done."



#88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888

#   Logger


#88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888

logger = logging.getLogger(module_name)
setup_std_logging(logger, options.log_file, options.verbose)

#88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888

#   Main logic


#88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
if not options.skip_parameter_logging:
  programme_name = os.path.split(sys.argv[0])[1]
  logger.info("%s %s" % (programme_name, " ".join(get_option_strings(parser, options))))


targeted_tasks = [
                  run_display
                  ] 

forced_tasks = []
if options.force:
    forced_tasks = []

if options.no_run_just_print:
    pipeline_printout(sys.stdout, targeted_tasks, forced_tasks, verbose = options.verbose)
elif options.graph_it:
    CURR_FILE_FORMAT = "svg"
    print "\n\nOnly printing a graphical representation of the pipeline\n./%s.%s\n\n" % (PIPELINE_NAME, CURR_FILE_FORMAT)
    pipeline_printout_graph("./%s.%s" % (PIPELINE_NAME, CURR_FILE_FORMAT), CURR_FILE_FORMAT, targeted_tasks, forcedtorun_tasks = forced_tasks, no_key_legend = True)
else:
    start_time = time.time()
    
    ###########
    # Sqlite scheduler deamon
    with sqlite_scheduler(options.database_file, "temp_run_folders/", ".request", ".queue") as deamon_running:
        pipeline_run(targeted_tasks, forced_tasks, multiprocess = MULTIPROCESSES, verbose = options.verbose)
    #pipeline_run(targeted_tasks, forced_tasks, multiprocess = MULTIPROCESSES, verbose = options.verbose)
    
    if int(round(time.time()-start_time, 0))/(60*60*24) >=1:
        print "\nTime taken for run: %d days, %d hours, %d mins, %d secs" % ( int(round(time.time()-start_time, 0))/(60*60*24), int(round(time.time()-start_time, 0))/(60*60)-((int(round(time.time()-start_time, 0))/(60*60*24))*24), int(round(time.time()-start_time, 0))/(60)-((int(round(time.time()-start_time, 0))/(60*60))*60), round(time.time()-start_time, 0)-((int(round(time.time()-start_time, 0))/60)*60) )
    elif int(round(time.time()-start_time, 0))/(60*60) >=1:
        print "\nTime taken for run: %d hours, %d mins, %d secs" % ( int(round(time.time()-start_time, 0))/(60*60), int(round(time.time()-start_time, 0))/(60)-((int(round(time.time()-start_time, 0))/(60*60))*60), round(time.time()-start_time, 0)-((int(round(time.time()-start_time, 0))/60)*60) )
    elif int(round(time.time()-start_time, 0))/(60) >=1:
        print "\nTime taken for run: %d mins, %d secs" % ( int(round(time.time()-start_time, 0))/(60), round(time.time()-start_time, 0)-((int(round(time.time()-start_time, 0))/60)*60) )
    else: 
        print "\nTime taken for run: %d secs" % ( round(time.time()-start_time, 0))

