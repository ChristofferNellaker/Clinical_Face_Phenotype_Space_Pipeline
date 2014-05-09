################################################################################
#path_to_meta_data_parser.py
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

##########################
# README NOTE
#
#  This is the script to parse image paths to the appropriate patient_id, gene or syndrome for later analysis.
#
#  You will need to build your own custom functions in here to make this work on your data
#
##########################


import sys, os, re, cPickle

def path_to_meta_data_parser(path_and_image):
    
    def SITW_parse(x,y):
        SITW_folder = x.split("/")[-2]
        ###########################
        # SPECIAL CASE
        #if SITW_folder = "image_10178mily":
            
        #
        ###########################
        for subfolder_index in range(0, len(x.split("/"))):
            if x.split("/")[subfolder_index] == "SITW_v2_parsed":
                SITW_folder = x.split("/")[subfolder_index+1] 
        flag_mirror = False
        if re.match(".+(mirror)", SITW_folder):
            SITW_folder = SITW_folder[:-7]
            flag_mirror = True
        if re.match(".+(PACS1)", x):
            return {
                "patient_id": SITW_folder + "/" + y,
                "gene": "PACS1",
                }
        SITW_folder_dict = {
                            "22q11":"22q11",
                            "FragileX":"FragileX",
                            "Marfan":"Marfan",
                            "Progeria":"Progeria",
                            "Progeria_new":"banana", #these are dupes and should not be used.
                            "Sotos":"Sotos",
                            "TCJPG":"Treacher-Collins",
                            "Turner":"Turner",
                            "angelmanJPG":"Angelman",
                            "apertJPG":"Apert",
                            "cdlHDJPG":"Cornelia_de_Lange_Syndrome",
                            "cdlJPG":"Cornelia_de_Lange_Syndrome",
                            "controles":"Control",
                            "downJPG":"Down",
                            "progeriaJPG":"Progeria",
                            "williamsJPG":"Williams",
                            }
        return {
                "patient_id": SITW_folder + "/" + y,
                "syndrome": SITW_folder_dict[SITW_folder]
                }
    
    def Bronwyn_parse(x,y):
        Bron_folder = x.split("/")[-2]
        if Bron_folder in set(["CFC", "Costello"]):
            return {
                    "patient_id":x+"/"+y,
                    "syndrome":Bron_folder,
                    }
        Bronwyn_dict = {
                        "BRAF":"BRAF",
                        "ERF":"ERF",
                        "HRAS":"HRAS",
                        "KRAS":"KRAS",
                        "MAP2K1":"MAP2K1",
                        "MAP2K2":"MAP2K2",
                        "MEK1":"MEK1",
                        "NRAS":"NRAS",
                        "PTPN11":"PTPN11",
                        "RAF1":"RAF1",
                        "SHOC2":"SHOC2",
                        "SOS1":"SOS1",
                        }
        return {
                "patient_id":x+"/"+y,
                "gene":Bronwyn_dict[Bron_folder],
                }
    
    def Gorlin_parse(x,y):
        Gorlin_folder = x.split("/")[-2]
        Gorlin_dict = {
                        "Aarskog":"Aarskog",
                        "Achondroplasia":"Achondroplasia",
                        "Alagille":"Alagille",
                        "Albright":"Albright",
                        "Angelman":"Angelman",
                        "Apert":"Apert",
                        "Apert_v2":"Apert",
                        "BOF":"BOF",
                        "Beckwith-Wiedemann":"Beckwith-Wiedemann",
                        "Bloom":"Bloom",
                        "CHARGE":"CHARGE",
                        "Cartilagehair":"Cartilagehair",
                        "Cherubism":"Cherubism",
                        "CleidoCranialdysostosis":"CleidoCranialdysostosis",
                        "Coffin-Lowry":"Coffin-Lowry",
                        "Costello":"Costello",
                        "CriduChat":"CriduChat",
                        "Crouzon":"Crouzon",
                        "Crouzonodermoskeletal":"Crouzonodermoskeletal",
                        "Cutislaxa":"Cutislaxa",
                        "DeLange":"Cornelia_de_Lange_Syndrome",
                        "Diastrophicdysplasia":"Diastrophicdysplasia",
                        "Down":"Down",
                        "Dubowitz":"Dubowitz",
                        "Dyggve-Melchior-Clausen":"Dyggve-Melchior-Clausen",
                        "EEC":"EEC",
                        "Ehlers-Danlos":"Ehlers-Danlos",
                        "Ellis-vanCreveld":"Ellis-vanCreveld",
                        "FG":"FG",
                        "FragileX":"FragileX",
                        "Frontometaphysealdysplasia":"Frontometaphysealdysplasia",
                        "Gorlin":"Gorlin",
                        "Gorlin_Chaudry_Moss":"Gorlin_Chaudry_Moss",
                        "Gorlin_v2":"Gorlin",
                        "Greig":"Greig",
                        "Hallermann-Streiff":"Hallermann-Streiff",
                        "Incontinentiapigmenti":"Incontinentiapigmenti",
                        "Kabuki":"Kabuki",
                        "Klippel-Feil":"Klippel-Feil",
                        "Klippel-Trenaunay":"Klippel-Trenaunay",
                        "Langer-Giedion":"Langer-Giedion",
                        "Larsen":"Larsen",
                        "Lenz_Majewski":"Lenz_Majewski",
                        "Lymphedema-Lymphangiectasia-MR":"Lymphedema-Lymphangiectasia-MR",
                        "Melnick_Needles":"Melnick_Needles",
                        "Moebius":"Moebius",
                        "Muenke":"Muenke",
                        "Myotonicdystrophy":"Myotonicdystrophy",
                        "Neurofibromatosis":"Neurofibromatosis",
                        "Noonan":"Noonan",
                        "OAVdysplasia":"OAVdysplasia",
                        "ODD":"ODD",
                        "OFCD":"OFCD",
                        "OFD":"OFD",
                        "OPD":"OPD",
                        "Osteopetrosis":"Osteopetrosis",
                        "Osteosclerosis":"Osteosclerosis",
                        "Otodental":"Otodental",
                        "Poland":"Poland",
                        "Prader-Willi":"Prader-Willi",
                        "Progeria":"Progeria",
                        "Proteus":"Proteus",
                        "Rieger":"Rieger",
                        "Rothmund-Thomson":"Rothmund-Thomson",
                        "Rubinstein-Taybi":"Rubinstein-Taybi",
                        "SEDcongenita":"SEDcongenita",
                        "Saethre-Chotzen":"Saethre-Chotzen",
                        "Sclerosteosis":"Sclerosteosis",
                        "SeckelMOD":"SeckelMOD",
                        "Sotos":"Sotos",
                        "Stickler":"Stickler",
                        "TRP":"TRP",
                        "Waardenburg":"Waardenburg",
                        "Weaver":"Weaver",
                        "Williams":"Williams",
                       }
        return {
                "patient_id":x+"/"+y,
                "syndrome":Gorlin_dict[Gorlin_folder],
                }
    

        
    
    [path_to_image, image_name] = os.path.split(os.path.abspath(path_and_image))
    if re.match("(/net/isi-backup/restricted/face/).+", path_to_image):
        if re.match(".+(SITW_v2_parsed).+", path_to_image):
            return SITW_parse(path_to_image, image_name)
        elif re.match(".+(Bronwyn).+", path_to_image):
            return Bronwyn_parse(path_to_image, image_name)
        elif re.match(".+(Gorlin).+", path_to_image):
            return Gorlin_parse(path_to_image, image_name)
        else: raise("Error, parser does not know of this format:\n%s\n\n" % path_and_image)
    elif re.match(".+(test_folder).+", path_to_image):
        return {"patient_id":path_and_image}     
    else: raise("Error, parser does not know of this format:\n%s\n\n" % path_and_image)
    