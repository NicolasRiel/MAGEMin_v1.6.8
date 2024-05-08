# Trace element partitioning prediction routine
# Note that only metapelite, metabasite and igneous database can be used for trace element prediction
# NR 11/04/2023

"""
    Classify the mineral output from MAGEMin to be able to be compared with partitioning coefficient database
"""
function mineral_classification(    out             :: MAGEMin_C.gmin_struct{Float64, Int64},
                                    dtb             :: String  )

    ph      = Array{String}(undef, out.n_SS + out.n_PP) 
    ph_wt   = Array{Float64}(undef, out.n_SS + out.n_PP) 

    # add solution phase and classify some solution phases (spn, fsp, ilm)                             
    for i = 1:out.n_SS                             
        ss      = out.ph[i]
        ph_wt[i]= out.ph_frac_wt[i]
        ph[i]   = ss
        if ss == "fsp"
            if out.SS_vec[i].compVariables[2] - 0.5 > 0
                ph[i] = "ksp"
            else
                ph[i] = "pl"
            end
        end
        if ss == "spn"
            if out.SS_vec[i].compVariables[3] - 0.5 > 0
                ph[i] = "cm"        # chromite
            else
                if out.SS_vec[i].compVariables[2] - 0.5 > 0
                    ph[i] = "mt"    # magnetite
                else
                    ph[i] = "sp"    # spinel
                end
            end
        end
        if ss == "sp"
            if out.SS_vec[i].compVariables[2] + out.SS_vec[i].compVariables[3] - 0.5 > 0
                ph[i] = "mt"        # chromite
            else
                if (1 - out.SS_vec[i].compVariables[1])*(1 + out.SS_vec[i].compVariables[3]) - 0.5 > 0
                    ph[i] = "sp"    # spinel
                else
                    if out.SS_vec[i].compVariables[3] -0.5 > 0
                        ph[i] = "FeTiOx"  # uvospinel
                    else
                        ph[i] = "sp" # hercynite
                    end
                end
            end
        end
        if ss == "dio" || ss == "aug"
            ph[i] = "cpx"
        end
        if ss == "ilm" || ss == "ilmm"
            ph[i] = "FeTiOx"
        end
        # add pure phases
        for i=1:out.n_PP
            ph[i+out.n_SS]      = out.ph[i+out.n_SS]
            ph_wt[i+out.n_SS]   = out.ph_frac_wt[i+out.n_SS]
        end
        
    end

    return ph, ph_wt
end



"""
    Holds the partitioning coefficient database
"""
struct KDs_database
    infos           :: String
    element_name    :: Vector{String}
    conditions      :: Tuple{String, Vector{Vector{Float64}}}
    phase_name      :: Tuple{Vector{String}, Vector{String}, Vector{String}}
    KDs             :: Tuple{Matrix{Float64}, Matrix{Float64}, Matrix{Float64}}
end


function get_OL_KDs_database()
    infos               = "Laurent, O. (2012). Les changements géodynamiques à la transition Archéen-Protérozoïque : étude des granitoïdes de la marge Nord du craton du Kaapvaal (Afrique du Sud). PhD, Université Blaise Pascal, Clermont-Ferrand."

    element_name        = ["Rb", "Ba", "Th", "U", "Nb", "Ta", "La", "Ce", "Pb", "Pr", "Sr", "Nd", "Zr", "Hf", "Sm", "Eu", "Gd", "Tb", "Dy", "Y", "Ho", "Er", "Tm", "Yb", "Lu", "V", "Sc"]
    conditions          = ("SiO2",[[0.0,52.0],[52.0,63.0],[63.0,100.0]])

    ph_1                = ["all", "hb", "ap", "bi", "cd", "cpx", "FeTiOx", "g", "ksp", "mt", "ol", "opx", "pl", "q", "ru", "sp", "ttn", "zrn", "ep", "and", "sill", "mu"]
    ph_2                = ["all"; "hb"; "ap"; "bi"; "cd"; "cpx"; "FeTiOx"; "g"; "ksp"; "mt"; "ol"; "opx"; "pl"; "q"; "ru"; "sp"; "ttn"; "zrn"]
    ph_3                = ["all"; "hb"; "ap"; "bi"; "cd"; "cpx"; "FeTiOx"; "g"; "ksp"; "mt"; "ol"; "opx"; "pl"; "q"; "ru"; "sp"; "ttn"; "zrn"; "ep"]

    KDs_1               = [0.0632455532033676 3.46410161513776 424.264068711929 20 0.447213595499958 2.73861278752583 1549.19333848297 1224.74487139159 0.316227766016838 1005.98210719674 1 793.725393319378 0.173205080756888 12.2474487139159 447.213595499958 97.9795897113271 254.950975679639 169.558249578132 118.321595661992 95.3939201416947 84.8528137423857 63.2455532033676 43.301270189222 26.8328157299975 17.7482393492988 1 57.0087712549569; 0.0547722557505166 0.189736659610103 0.212132034355964 0.821583836257749 2 0.4 0.559016994374947 1 0.632455532033676 1.59687194226713 0.387298334620742 2.64575131106459 0.632455532033676 0.707106781186547 3.46410161513776 3.46410161513776 4.74341649025257 5.37354631505117 5.42217668469038 5.74456264653803 5.24404424085076 4.96990945591567 4.5 3.74165738677394 2.95803989154981 6.70820393249937 14.142135623731; 0.00316227766016838 0.273861278752583 1 0.948683298050514 0.0316227766016838 0.0316227766016838 13.228756555323 21.2132034355964 0.158113883008419 30.5777697028413 7.07106781186548 40.3112887414928 0.387298334620742 0.387298334620742 47.4341649025257 21.2132034355964 52.9150262212919 52.9150262212919 45.8257569495584 38.7298334620742 37.0809924354783 30 22.9128784747792 15.8113883008419 12.5499003980111 0.316227766016838 0.316227766016838; 4 6.70820393249937 0.316227766016838 0.316227766016838 6.32455532033676 1.89736659610103 1.26491106406735 0.948683298050514 0.316227766016838 0.790569415042095 0.223606797749979 0.790569415042095 0.632455532033676 0.632455532033676 0.632455532033676 0.316227766016838 0.51234753829798 0.521536192416212 0.519615242270663 0.774596669241483 0.53851648071345 0.554977477020464 0.557225268630201 0.558569601750758 0.559016994374947 3.16227766016838 9.21954445729289; 0.106066017177982 0.0223606797749979 0.193649167310371 0.632455532033676 0.0316227766016838 0.0316227766016838 0.0741619848709566 0.0848528137423857 0.0316227766016838 0.0989949493661167 0.187082869338697 0.12 0.0612372435695794 0.0774596669241483 0.173205080756888 0.0316227766016838 0.403112887414927 0.670820393249937 1.14564392373896 0.987420882906575 1.58113883008419 2.29128784747792 2.80624304008046 3.16227766016838 3.51781181986757 0.447213595499958 2.23606797749979; 0.0316227766016838 0.122474487139159 0.14142135623731 0.154919333848297 0.109544511501033 0.154919333848297 0.632455532033676 1.09544511501033 0.223606797749979 1.48323969741913 0.335410196624968 1.93649167310371 0.387298334620742 0.547722557505166 2.32379000772445 2.77488738510232 3.06186217847897 3.46410161513775 3.57770876399966 3.24037034920393 3.35410196624969 3.1859064644148 3.07408522978788 2.89827534923789 2.77488738510232 4.74341649025257 26.4575131106459; 0.0223606797749979 0.0223606797749979 0.387298334620742 0.387298334620742 28.2842712474619 44.7213595499958 3.35410196624968 2.82842712474619 0.447213595499958 2.57875939164553 0.193649167310371 2.50998007960223 1.58113883008419 1.58113883008419 2.36643191323985 0.632455532033676 2.36643191323985 1.89736659610103 1.58113883008419 0.447213595499958 1.58113883008419 1.58113883008419 1.42302494707577 1.26491106406735 1.26491106406735 31.6227766016838 4.47213595499958; 0.00790569415042094 0.0173205080756888 0.0774596669241483 0.158113883008419 0.0316227766016838 0.0707106781186547 0.1 0.237170824512628 0.0316227766016838 0.460977222864644 0.0223606797749979 0.866025403784439 0.447213595499958 0.707106781186547 1.93649167310371 1.58113883008419 6.12372435695795 11.180339887499 22.3606797749979 25.4950975679639 32.4037034920393 41.2310562561766 44.7213595499958 44.7213595499958 37.4165738677394 4.47213595499958 22.3606797749979; 0.948683298050514 9.48683298050514 0.0144913767461894 0.0158113883008419 0.0447213595499958 0.00707106781186547 0.14142135623731 0.0866025403784439 0.948683298050514 0.0547722557505166 3.87298334620742 0.0316227766016838 0.0193649167310371 0.0158113883008419 0.0187082869338697 3.87298334620742 0.0187082869338697 0.0167332005306815 0.02 0.0316227766016838 0.02 0.0223606797749979 0.0234520787991171 0.0234520787991171 0.0244948974278318 0.223606797749979 0.0316227766016838; 0.0223606797749979 0.0223606797749979 0.221359436211787 0.447213595499958 1.67332005306815 2.12132034355964 1.02469507659596 1 0.547722557505166 1.06066017177982 0.0264575131106459 1.09544511501033 0.670820393249937 0.707106781186547 1.09544511501033 0.948683298050514 1.18321595661992 1.18321595661992 1.10679718105893 0.948683298050514 1.02469507659596 0.866025403784439 0.866025403784439 0.707106781186547 0.547722557505166 36.0555127546399 8.66025403784439; 0.0223606797749979 0.03 0.02 0.0154919333848297 0.031224989991992 0.0335410196624968 0.0670820393249937 0.0774596669241483 0.158113883008419 0.0916515138991168 0.13228756555323 0.106066017177982 0.025298221281347 0.0284604989415154 0.121963109176505 0.14142135623731 0.13228756555323 0.154919333848297 0.175499287747842 0.126491106406735 0.193649167310371 0.232379000772445 0.277488738510232 0.316227766016838 0.387298334620742 0.244948974278318 0.447213595499958; 0.0158113883008419 0.05 0.158113883008419 0.158113883008419 0.25298221281347 0.316227766016838 0.158113883008419 0.239791576165636 0.0894427190999916 0.289827534923789 0.0447213595499958 0.353553390593274 0.0547722557505166 0.0948683298050513 0.424264068711928 0.316227766016838 0.58309518948453 0.724568837309472 0.848528137423857 0.774596669241483 0.924662100445346 1 1.16189500386223 1.2747548783982 1.54919333848297 3.16227766016838 22.3606797749979; 0.126491106406735 0.632455532033676 0.0547722557505166 0.1 0.1 0.0670820393249937 0.387298334620742 0.284604989415154 0.670820393249937 0.221359436211786 4.47213595499958 0.158113883008419 0.0894427190999916 0.0670820393249937 0.126491106406735 2.73861278752583 0.116189500386222 0.102469507659596 0.0948683298050513 0.1 0.0774596669241483 0.0692820323027551 0.0574456264653803 0.0524404424085076 0.0447213595499958 0.158113883008419 0.0316227766016838; 0.00316227766016838 0.00316227766016838 0.00316227766016838 0.00316227766016838 0.00316227766016838 0.00316227766016838 0.00316227766016838 0.00316227766016838 0.00316227766016838 0.00316227766016838 0.00316227766016838 0.00316227766016838 0.00316227766016838 0.00316227766016838 0.00316227766016838 0.00316227766016838 0.00316227766016838 0.00316227766016838 0.00316227766016838 0.00316227766016838 0.00316227766016838 0.00316227766016838 0.00316227766016838 0.00316227766016838 0.00316227766016838 0.00316227766016838 0.00316227766016838; 0.0118321595661992 0.01 0.335410196624968 0.335410196624968 61.2372435695795 27.3861278752583 0.0353553390593274 0.0458257569495584 0.0316227766016838 0.0494974746830583 0.0707106781186547 0.0565685424949238 3.46410161513776 5.29150262212918 0.0565685424949238 0.00111803398874989 0.0354964786985977 0.0278208554864871 0.0256904651573302 0.0707106781186547 0.0241867732448956 0.0217944947177034 0.0185202591774521 0.0173205080756888 0.0158113883008419 47.4341649025257 0.316227766016838; 0.00547722557505166 0.00223606797749979 0.00790569415042094 0.013228756555323 0.0707106781186547 0.0707106781186547 0.00244948974278318 0.00387298334620742 0.000316227766016838 0.006 0.00346410161513776 0.00812403840463596 0.0790569415042095 0.1 0.0116189500386222 0.0106066017177982 0.0144913767461894 0.0149666295470958 0.015 0.0158113883008419 0.0141421356237309 0.0132664991614216 0.0130384048104053 0.012369316876853 0.0116189500386222 8.36660026534076 0.316227766016838; 0.4 1.36930639376292 0.223606797749979 0.2 3.46410161513776 8.66025403784439 6 7.41619848709567 0.223606797749979 8.83176086632785 2.23606797749979 10.2469507659596 1.34164078649987 1.73205080756888 10.9544511501033 8.06225774829855 10.2469507659596 9.2951600308978 7.88035532193822 6 6.557438524302 5.17010638188423 3.73496987939662 2.56904651573303 1.67332005306815 5.47722557505166 2.23606797749979; 0.632455532033676 0.632455532033676 18.02775637732 31.6227766016838 22.3606797749979 22.3606797749979 1.26491106406735 3.46410161513776 0.1 2 4.47213595499958 2.82842712474619 948.683298050515 948.683298050515 7.74596669241484 2.23606797749979 20.4939015319192 28.4604989415154 44.1588043316392 67.0820393249938 73.4846922834954 110 139.64240043769 173.205080756888 223.606797749979 0.1 63.2455532033676; 0.0045 0.408 156 1.29 0.226 0.226 2.05 2.44 0.5 2.85475042692001 2 3.34 0.1 10 4.22 3.78 4.67 4.58421203698084 4.5 4.3 4.12431812546026 3.78 3.34496636754392 2.96 2.61933874283863 0.1 0.0001; 1.0e-5 1.0e-5 1.0e-5 1.0e-5 1.0e-5 1.0e-5 1.0e-5 1.0e-5 1.0e-5 1.0e-5 1.0e-5 1.0e-5 1.0e-5 1.0e-5 1.0e-5 1.0e-5 1.0e-5 1.0e-5 1.0e-5 1.0e-5 1.0e-5 1.0e-5 1.0e-5 1.0e-5 1.0e-5 1.0e-5 1.0e-5; 1.0e-5 1.0e-5 1.0e-5 1.0e-5 1.0e-5 1.0e-5 1.0e-5 1.0e-5 1.0e-5 1.0e-5 1.0e-5 1.0e-5 1.0e-5 1.0e-5 1.0e-5 1.0e-5 1.0e-5 1.0e-5 1.0e-5 1.0e-5 1.0e-5 1.0e-5 1.0e-5 1.0e-5 1.0e-5 1.0e-5 1.0e-5; 1.0e-5 1.0e-5 1.0e-5 1.0e-5 1.0e-5 1.0e-5 1.0e-5 1.0e-5 1.0e-5 1.0e-5 1.0e-5 1.0e-5 1.0e-5 1.0e-5 1.0e-5 1.0e-5 1.0e-5 1.0e-5 1.0e-5 1.0e-5 1.0e-5 1.0e-5 1.0e-5 1.0e-5 1.0e-5 1.0e-5 1.0e-5];
    KDs_2               = [0.0632455532033676 3.46410161513776 324.037034920393 13.228756555323 0.836660026534076 0.836660026534076 1414.2135623731 1174.73401244707 1 948.683298050515 1 612.372435695795 0.173205080756888 11.180339887499 300 34.6410161513775 116.189500386222 58.309518948453 31.6227766016838 31.6227766016838 18.9736659610103 13.4164078649987 10.2469507659596 7.74596669241484 6.70820393249937 1 57.0087712549569; 0.122474487139159 0.223606797749979 0.14142135623731 0.1 0.559016994374947 0.273861278752583 0.335410196624968 0.412310562561766 0.223606797749979 0.574456264653803 0.273861278752583 0.866025403784439 0.4 0.547722557505166 1.36930639376292 1 1.80277563773199 2.21359436211787 2.29128784747792 2.12132034355964 2.08566536146142 1.8165902124585 1.51657508881031 1.40712472794703 1.30384048104053 5.47722557505166 10; 0.00316227766016838 0.0790569415042095 0.790569415042095 0.387298334620742 0.00353553390593274 0.00707106781186547 3.87298334620742 7.07106781186548 0.316227766016838 11.0679718105893 1.93649167310371 15 0.193649167310371 0.0707106781186547 17.3205080756888 11.180339887499 18.3711730708738 17.8885438199983 15.6524758424985 12.2474487139159 13.4164078649987 11.180339887499 8.94427190999916 6.70820393249937 4.47213595499958 0.223606797749979 0.316227766016838; 3.16227766016838 5.47722557505166 0.0474341649025257 0.0707106781186547 0.474341649025257 0.316227766016838 0.0591607978309961 0.06 0.0316227766016838 0.0648074069840786 0.234520787991171 0.0670820393249937 0.229128784747792 0.316227766016838 0.0707106781186547 0.13228756555323 0.0741619848709566 0.0774596669241483 0.0793725393319377 0.111803398874989 0.0774596669241483 0.0747663025700749 0.0734846922834953 0.0726636084983398 0.0707106781186547 3.16227766016838 9.21954445729289; 0.106066017177982 0.0223606797749979 0.193649167310371 0.632455532033676 0.0316227766016838 0.0316227766016838 0.0741619848709566 0.0848528137423857 0.0316227766016838 0.0989949493661167 0.187082869338697 0.12 0.0612372435695794 0.0774596669241483 0.173205080756888 0.0316227766016838 0.403112887414927 0.670820393249937 1.14564392373896 0.987420882906575 1.58113883008419 2.29128784747792 2.80624304008046 3.16227766016838 3.51781181986757 0.447213595499958 2.23606797749979; 0.0316227766016838 0.0547722557505166 0.0707106781186547 0.0447213595499958 0.111803398874989 0.0707106781186547 0.13228756555323 0.212132034355964 0.316227766016838 0.290688837074973 0.287228132326901 0.401870625948202 0.234520787991171 0.31224989991992 0.5 0.692820323027551 0.725603197346869 0.848528137423857 0.953939201416946 1.09544511501033 1.06348483769163 1.14105214604767 1.18215904175369 1.1861703081767 1.18321595661992 1.93649167310371 7.74596669241484; 0.00316227766016838 0.00447213595499958 0.0158113883008419 0.0237170824512628 4.47213595499958 6.70820393249937 0.0223606797749979 0.0306186217847897 0.0158113883008419 0.0367423461417476 0.00632455532033676 0.0412310562561766 1.22474487139159 1.5 0.0547722557505166 0.0447213595499958 0.0790569415042095 0.09 0.0989949493661167 0.0707106781186547 0.101980390271856 0.111803398874989 0.117260393995586 0.117473401244707 0.109544511501033 11.180339887499 1.73205080756888; 0.00836660026534076 0.0154919333848297 0.0474341649025257 0.0935414346693485 0.0264575131106459 0.05 0.0264575131106459 0.0519615242270663 0.0316227766016838 0.102469507659596 0.0173205080756888 0.205548047910945 0.547722557505166 0.387298334620742 0.433012701892219 0.5 1.58113883008419 3.16227766016838 5.45435605731786 6.12372435695795 8.2915619758885 9.89949493661167 10.0623058987491 9.35414346693486 7.74596669241484 2.64575131106459 3.16227766016838; 0.948683298050514 5.47722557505166 0.0173205080756888 0.0273861278752583 0.0158113883008419 0.00316227766016838 0.111803398874989 0.0670820393249937 0.223606797749979 0.0447213595499958 2.23606797749979 0.03 0.0223606797749979 0.0223606797749979 0.0212132034355964 3.35410196624969 0.0167332005306815 0.015 0.0144913767461894 0.0254950975679639 0.0162018517460197 0.0189736659610103 0.02 0.0232379000772445 0.0273861278752583 0.111803398874989 0.02; 0.0387298334620742 0.158113883008419 0.0935414346693485 0.13228756555323 0.136930639376291 0.122474487139159 0.14142135623731 0.189736659610103 0.316227766016838 0.234520787991171 0.0223606797749979 0.267394839142419 0.220794021658196 0.158113883008419 0.3 0.254950975679639 0.324037034920393 0.31224989991992 0.301662062579967 0.335410196624968 0.268328157299975 0.245967477524977 0.234520787991171 0.223606797749979 0.212132034355964 22.3606797749979 3.16227766016838; 0.013228756555323 0.0122474487139159 0.0154919333848297 0.0223606797749979 0.0193649167310371 0.0273861278752583 0.00273861278752583 0.00489897948556636 0.0187082869338697 0.00790569415042094 0.01 0.0116189500386222 0.0387298334620742 0.0223606797749979 0.0152970585407783 0.0187616630392937 0.0228035085019828 0.0270554985169374 0.0324037034920393 0.0346410161513775 0.0369864840178138 0.04 0.0439545219516718 0.0474341649025257 0.0529150262212918 0.16431676725155 0.433012701892219; 0.0244948974278318 0.0316227766016838 0.1 0.0316227766016838 0.05 0.0670820393249937 0.00894427190999916 0.0204939015319192 0.111803398874989 0.0363318042491699 0.0193649167310371 0.0574456264653803 0.0346410161513775 0.0547722557505166 0.0812403840463596 0.114017542509914 0.157480157480236 0.207846096908265 0.256124969497314 0.282842712474619 0.311126983722081 0.351425667816112 0.4 0.458257569495584 0.5 1.5 5.47722557505166; 0.0447213595499958 0.387298334620742 0.0316227766016838 0.0547722557505166 0.0612372435695794 0.0447213595499958 0.2 0.154919333848297 0.5 0.122474487139159 2.44948974278318 0.106066017177982 0.0223606797749979 0.0324037034920393 0.0774596669241483 1.1180339887499 0.0447213595499958 0.0367423461417476 0.03 0.0292403830344269 0.0256904651573302 0.0212132034355964 0.0182345825288105 0.0169705627484771 0.0154919333848297 0.158113883008419 0.0316227766016838; 0.00316227766016838 0.00316227766016838 0.00316227766016838 0.00316227766016838 0.00316227766016838 0.00316227766016838 0.00316227766016838 0.00316227766016838 0.00316227766016838 0.00316227766016838 0.00316227766016838 0.00316227766016838 0.00316227766016838 0.00316227766016838 0.00316227766016838 0.00316227766016838 0.00316227766016838 0.00316227766016838 0.00316227766016838 0.00316227766016838 0.00316227766016838 0.00316227766016838 0.00316227766016838 0.00316227766016838 0.00316227766016838 0.00316227766016838 0.00316227766016838; 0.01 0.00866025403784438 0.162018517460196 0.2 33.5410196624969 22.3606797749979 0.0111803398874989 0.0141421356237309 0.0273861278752583 0.0156524758424985 0.0316227766016838 0.0172481883106603 2.23606797749979 3.74165738677394 0.0184932420089069 0.000632455532033676 0.0194935886896179 0.0204939015319192 0.022248595461287 0.0273861278752583 0.024 0.0264575131106459 0.0291204395571221 0.0314642654451045 0.033466401061363 3.16227766016838 0.273861278752583; 0.00547722557505166 0.00223606797749979 0.00790569415042094 0.013228756555323 0.0707106781186547 0.0707106781186547 0.00244948974278318 0.00387298334620742 0.000316227766016838 0.006 0.00346410161513776 0.00812403840463596 0.0790569415042095 0.1 0.0116189500386222 0.0106066017177982 0.0144913767461894 0.0149666295470958 0.015 0.0158113883008419 0.0141421356237309 0.0132664991614216 0.0130384048104053 0.012369316876853 0.0116189500386222 8.36660026534076 0.316227766016838; 0.4 1.36930639376292 0.223606797749979 0.2 3.46410161513776 8.66025403784439 6 7.41619848709567 0.223606797749979 8.83176086632785 2.23606797749979 10.2469507659596 1.34164078649987 1.73205080756888 10.9544511501033 8.06225774829855 10.2469507659596 9.2951600308978 7.88035532193822 6 6.557438524302 5.17010638188423 3.73496987939662 2.56904651573303 1.67332005306815 5.47722557505166 2.23606797749979; 0.632455532033676 0.632455532033676 18.02775637732 31.6227766016838 22.3606797749979 22.3606797749979 1.26491106406735 3.46410161513776 0.1 2 4.47213595499958 2.82842712474619 948.683298050515 948.683298050515 7.74596669241484 2.23606797749979 20.4939015319192 28.4604989415154 44.1588043316392 67.0820393249938 73.4846922834954 110 139.64240043769 173.205080756888 223.606797749979 0.1 63.2455532033676]
    KDs_3               = [0.0632455532033676 3.46410161513776 324.037034920393 13.228756555323 0.836660026534076 0.836660026534076 1414.2135623731 1174.73401244707 1 948.683298050515 1 612.372435695795 0.173205080756888 11.180339887499 300 34.6410161513775 116.189500386222 58.309518948453 31.6227766016838 31.6227766016838 18.9736659610103 13.4164078649987 10.2469507659596 7.74596669241484 6.70820393249937 1 57.0087712549569; 0.223606797749979 0.31224989991992 0.0141421356237309 0.0193649167310371 0.158113883008419 0.220794021658196 0.0724568837309472 0.144913767461894 0.0632455532033676 0.234520787991171 0.3 0.346410161513775 0.335410196624968 0.391152144312159 0.447213595499958 0.524404424085076 0.589915248150105 0.634822809924155 0.66932802122726 0.612372435695794 0.681175454637056 0.648074069840786 0.603738353924943 0.53619026473818 0.458257569495584 4.89897948556636 3.87298334620742; 0.00316227766016838 0.0790569415042095 0.790569415042095 0.387298334620742 0.00353553390593274 0.00707106781186547 3.87298334620742 7.07106781186548 0.316227766016838 11.0679718105893 1.93649167310371 15 0.193649167310371 0.0707106781186547 17.3205080756888 11.180339887499 18.3711730708738 17.8885438199983 15.6524758424985 12.2474487139159 13.4164078649987 11.180339887499 8.94427190999916 6.70820393249937 4.47213595499958 0.223606797749979 0.316227766016838; 2 4.47213595499958 0.0474341649025257 0.0707106781186547 0.273861278752583 0.187082869338697 0.0144913767461894 0.0189736659610103 0.0316227766016838 0.0244948974278318 0.234520787991171 0.031224989991992 0.0547722557505166 0.0547722557505166 0.0387298334620742 0.0418330013267038 0.0447213595499958 0.0519615242270663 0.0591607978309961 0.066332495807108 0.0692820323027551 0.0747663025700749 0.0793725393319377 0.0819756061276768 0.0866025403784439 3.16227766016838 9.21954445729289; 0.106066017177982 0.0223606797749979 0.193649167310371 0.632455532033676 0.0316227766016838 0.0316227766016838 0.0741619848709566 0.0848528137423857 0.0316227766016838 0.0989949493661167 0.187082869338697 0.12 0.0612372435695794 0.0774596669241483 0.173205080756888 0.0316227766016838 0.403112887414927 0.670820393249937 1.14564392373896 0.987420882906575 1.58113883008419 2.29128784747792 2.80624304008046 3.16227766016838 3.51781181986757 0.447213595499958 2.23606797749979; 0.00948683298050514 0.005 0.00935414346693485 0.00707106781186547 0.00894427190999916 0.0180277563773199 0.0474341649025257 0.0866025403784439 0.0223606797749979 0.14456832294801 0.122474487139159 0.216333076527839 0.0707106781186547 0.187082869338697 0.301662062579967 0.387298334620742 0.460977222864644 0.522494019104525 0.551361950083609 0.6 0.585662018573853 0.608276253029822 0.608276253029822 0.585662018573853 0.559910707166777 1.58113883008419 4.74341649025257; 0.00316227766016838 0.00447213595499958 0.0158113883008419 0.0237170824512628 4.47213595499958 6.70820393249937 0.0223606797749979 0.0306186217847897 0.0158113883008419 0.0367423461417476 0.00632455532033676 0.0412310562561766 1.22474487139159 1.5 0.0547722557505166 0.0447213595499958 0.0790569415042095 0.09 0.0989949493661167 0.0707106781186547 0.101980390271856 0.111803398874989 0.117260393995586 0.117473401244707 0.109544511501033 11.180339887499 1.73205080756888; 0.000866025403784438 0.000387298334620741 0.002 0.00612372435695794 0.013228756555323 0.0180277563773199 0.00894427190999916 0.0219089023002067 0.0122474487139159 0.0565685424949238 0.013228756555323 0.122474487139159 0.3 0.252487623459052 0.264575131106459 0.424264068711928 0.821583836257749 1.3228756555323 1.93649167310371 2.32379000772445 2.54950975679639 3.1224989991992 3.51781181986757 4.02336923485777 4.47213595499958 2.44948974278318 3.74165738677394; 0.948683298050514 5.47722557505166 0.0173205080756888 0.0273861278752583 0.0158113883008419 0.00316227766016838 0.111803398874989 0.0670820393249937 0.223606797749979 0.0447213595499958 2.23606797749979 0.03 0.0223606797749979 0.0223606797749979 0.0212132034355964 3.35410196624969 0.0167332005306815 0.015 0.0144913767461894 0.0254950975679639 0.0162018517460197 0.0189736659610103 0.02 0.0232379000772445 0.0273861278752583 0.111803398874989 0.02; 0.0158113883008419 0.0158113883008419 0.0387298334620742 0.0387298334620742 0.1 0.1 0.0126491106406735 0.0273861278752583 0.0591607978309961 0.0474341649025257 0.0122474487139159 0.062449979983984 0.150831031289984 0.2 0.0724568837309471 0.0360555127546399 0.0774596669241483 0.0702851335632223 0.0666333249958307 0.0591607978309961 0.0620483682299543 0.0565685424949238 0.0547722557505166 0.05 0.0447213595499958 6.32455532033676 1.4142135623731; 0.00223606797749979 0.00223606797749979 0.000707106781186547 0.000707106781186547 0.00273861278752583 0.005 0.000223606797749979 0.000447213595499958 0.000193649167310371 0.000935414346693485 0.000109544511501033 0.00158113883008419 0.00316227766016838 0.00547722557505166 0.00250998007960223 0.00316227766016838 0.00424264068711928 0.0062928530890209 0.00908295106229247 0.00774596669241483 0.013228756555323 0.0193649167310371 0.0241867732448956 0.0273861278752583 0.0282842712474619 0.0774596669241483 0.287228132326901; 0.00547722557505166 0.00173205080756888 0.000316227766016838 0.0005 0.00346410161513776 0.00632455532033676 0.000836660026534075 0.00264575131106459 0.02 0.00547722557505166 0.0141421356237309 0.0109544511501033 0.0291547594742265 0.0547722557505166 0.0180277563773199 0.0223606797749979 0.0324037034920393 0.0412310562561766 0.05 0.0670820393249937 0.0619677335393187 0.0734846922834953 0.0916515138991168 0.107238052947636 0.120415945787923 1 1.22474487139159; 0.0547722557505166 0.335410196624968 0.1 0.0632455532033676 0.0447213595499958 0.0447213595499958 0.111803398874989 0.0894427190999916 0.591607978309962 0.0714142842854285 1.6583123951777 0.0591607978309961 0.01 0.0154919333848297 0.0489897948556635 0.707106781186547 0.0387298334620742 0.0338230690505755 0.03 0.0357071421427143 0.0267394839142419 0.0240831891575846 0.0222261107708929 0.0203469899493758 0.0178885438199983 0.0670820393249937 0.0316227766016838; 0.00316227766016838 0.00316227766016838 0.00316227766016838 0.00316227766016838 0.00316227766016838 0.00316227766016838 0.00316227766016838 0.00316227766016838 0.00316227766016838 0.00316227766016838 0.00316227766016838 0.00316227766016838 0.00316227766016838 0.00316227766016838 0.00316227766016838 0.00316227766016838 0.00316227766016838 0.00316227766016838 0.00316227766016838 0.00316227766016838 0.00316227766016838 0.00316227766016838 0.00316227766016838 0.00316227766016838 0.00316227766016838 0.00316227766016838 0.00316227766016838; 0.01 0.00866025403784438 0.162018517460196 0.2 33.5410196624969 22.3606797749979 0.0111803398874989 0.0141421356237309 0.0273861278752583 0.0156524758424985 0.0316227766016838 0.0172481883106603 2.23606797749979 3.74165738677394 0.0184932420089069 0.000632455532033676 0.0194935886896179 0.0204939015319192 0.022248595461287 0.0273861278752583 0.024 0.0264575131106459 0.0291204395571221 0.0314642654451045 0.033466401061363 3.16227766016838 0.273861278752583; 0.00547722557505166 0.00223606797749979 0.00790569415042094 0.013228756555323 0.0707106781186547 0.0707106781186547 0.00244948974278318 0.00387298334620742 0.000316227766016838 0.006 0.00346410161513776 0.00812403840463596 0.0790569415042095 0.1 0.0116189500386222 0.0106066017177982 0.0144913767461894 0.0149666295470958 0.015 0.0158113883008419 0.0141421356237309 0.0132664991614216 0.0130384048104053 0.012369316876853 0.0116189500386222 8.36660026534076 0.316227766016838; 0.4 1.36930639376292 0.223606797749979 0.2 3.46410161513776 8.66025403784439 6 7.41619848709567 0.223606797749979 8.83176086632785 2.23606797749979 10.2469507659596 1.34164078649987 1.73205080756888 10.9544511501033 8.06225774829855 10.2469507659596 9.2951600308978 7.88035532193822 6 6.557438524302 5.17010638188423 3.73496987939662 2.56904651573303 1.67332005306815 5.47722557505166 2.23606797749979; 0.632455532033676 0.632455532033676 18.02775637732 31.6227766016838 22.3606797749979 22.3606797749979 1.26491106406735 0.1 0.316227766016838 2 4.47213595499958 2.82842712474619 948.683298050515 948.683298050515 7.74596669241484 2.23606797749979 20.4939015319192 28.4604989415154 44.1588043316392 67.0820393249938 73.4846922834954 110 139.64240043769 173.205080756888 223.606797749979 0.1 63.2455532033676; 0.0045 0.408 156 1.29 0.226 0.226 2.05 2.44 0.5 2.89 2 3.78 0.1 10 4.22 3.78 4.67 4.59 4.5 4.3 4.14 3.78 3.37 2.96 2.55 0.1 0.0001]

    # phase_name          = (mineral_name_convertor(ph_1),mineral_name_convertor(ph_2),mineral_name_convertor(ph_3))
    phase_name          = (ph_1,ph_2,ph_3)
    KDs                 = (KDs_1,KDs_2,KDs_3)

    KDs_dtb             = KDs_database(infos, element_name,conditions,phase_name,KDs)

    return KDs_dtb
end


function adjust_chemical_system(    KDs_dtb     :: KDs_database,
                                    bulk_TE     :: Vector{Float64},
                                    elem_TE     :: Vector{String})

    C0_TE_idx   = [findfirst(isequal(x), elem_TE) for x in KDs_dtb.element_name]
    C0_TE       = bulk_TE[C0_TE_idx]
    
    return C0_TE
end


struct out_tepm
    Cliq        :: Union{Nothing, Vector{Float64}}
    Cmin        :: Union{Nothing, Matrix{Float64}}
    ph_TE       :: Union{Nothing, Vector{String}}
    ph_wt_norm  :: Union{Nothing, Vector{Float64}}
    liq_wt_norm :: Union{Nothing, Float64}
    Cliq_Zr     :: Union{Nothing, Float64}
    Sat_zr_liq  :: Union{Nothing, Float64}
    zrc_wt      :: Union{Nothing, Float64}
    bulk_cor_wt :: Union{Nothing, Vector{Float64}}
end


function TE_prediction(     C0         :: Vector{Float64},
                            KDs_dtb    :: KDs_database,
                            ZrSat_model:: String,
                            out        :: MAGEMin_C.gmin_struct{Float64, Int64},
                            dtb        :: String )

    # ox_id = -1                      
    # for (i, val) in enumerate(out.oxides)
    #     if string(val) == KDs_dtb.conditions[1]
    #         ox_id = i
    #         break
    #     end
    # end  
    ox_id   = findfirst(out.oxides .== KDs_dtb.conditions[1])[1]

    ox_M    = out.bulk_M_wt[ox_id]
    liq_wt  = out.frac_M_wt
    sol_wt  = out.frac_S_wt

    if liq_wt > 0.0 && liq_wt < 1.0 && sol_wt > 0.0
        n_cond  = length(KDs_dtb.conditions[2])
        cond    = -1
        for i=1:n_cond
            if ox_M > KDs_dtb.conditions[2][i][1] && ox_M < KDs_dtb.conditions[2][i][2]
                cond = i
                break
            end
        end

        ph, ph_wt   =  mineral_classification(out, dtb);
        TE_ph       =  intersect(ph,KDs_dtb.phase_name[cond]);

        # get indexes of the phase with respect to MAGEMin output and TE_database
        MM_ph_idx   = [findfirst(isequal(x), ph) for x in TE_ph];
        TE_ph_idx   = [findfirst(isequal(x), KDs_dtb.phase_name[cond]) for x in TE_ph];

        # normalize phase fractions
        sum_ph_frac = sum(ph_wt[MM_ph_idx]);
        liq_wt_norm = liq_wt/(sum_ph_frac+liq_wt);
        ph_wt_norm  = ph_wt[MM_ph_idx]./sum_ph_frac;
        ph_TE       = ph[MM_ph_idx];

        # compute bulk distributiion coefficient
        D           = KDs_dtb.KDs[cond][TE_ph_idx,:]'*ph_wt_norm;

        Cliq        = C0 ./ (D .+ liq_wt_norm.*(1.0 .- D));
        Cmin        = similar(KDs_dtb.KDs[cond][TE_ph_idx,:]); 

        for i = 1:length(ph_wt_norm)
            Cmin[i,:] = KDs_dtb.KDs[cond][TE_ph_idx[i],:] .* Cliq;
        end

        id_Zr       = findfirst(KDs_dtb.element_name .== "Zr")[1]
        Cliq_Zr     = Cliq[id_Zr]

        Sat_zr_liq  = zirconium_saturation( out; 
                                            model = ZrSat_model)   

        if Cliq_Zr > Sat_zr_liq
            zrc_wt, SiO2_zrc_wt, O_wt       = adjust_bulk_4_zircon(Cliq_Zr, Sat_zr_liq)


            # SiO2_id = -1                      
            # for (i, val) in enumerate(out.oxides)
            #     if string(val) == "SiO2"
            #         SiO2_id = i
            #         break
            #     end
            # end  
            SiO2_id                         = findall(out.oxides .== "SiO2")[1]

            bulk_cor_wt                     = copy(out.bulk_wt)
            bulk_cor_wt[SiO2_id]            = out.bulk_wt[SiO2_id] - SiO2_zrc_wt 
            bulk_cor_wt                   ./= sum(bulk_cor_wt)
        else
            zrc_wt, bulk_cor_wt = nothing, nothing
        end

    elseif liq_wt == 0.0
        Cliq, Cmin, ph_TE, ph_wt_norm, liq_wt_norm, Cliq_Zr, Sat_zr_liq, zrc_wt, bulk_cor_wt = nothing, nothing, nothing, nothing, nothing, nothing, nothing, nothing, nothing
    elseif liq_wt == 1.0
        Cliq        = C0

        # id_Zr = -1                      
        # for (i, val) in enumerate(KDs_dtb.element_name)
        #     if string(val) == "Zr"
        #         id_Zr = i
        #         break
        #     end
        # end  
        id_Zr       = findfirst(KDs_dtb.element_name .== "Zr")[1]

        Cliq_Zr     = Cliq[id_Zr]
        Cmin, ph_TE, ph_wt_norm, zrc_wt = nothing, nothing, nothing, nothing
        Sat_zr_liq  = zirconium_saturation( out; 
                                            model = ZrSat_model)   

        if Cliq_Zr > Sat_zr_liq
            zrc_wt, SiO2_zrc_wt, O_wt       = adjust_bulk_4_zircon(Cliq_Zr, Sat_zr_liq)

            # SiO2_id = -1                      
            # for (i, val) in enumerate(out.oxides)
            #     if string(val) == "SiO2"
            #         SiO2_id = i
            #         break
            #     end
            # end  
            SiO2_id                         = findall(out.oxides .== "SiO2")[1]

            bulk_cor_wt                     = copy(out.bulk_wt)
            bulk_cor_wt[SiO2_id]            = out.bulk_wt[SiO2_id] - SiO2_zrc_wt 
            bulk_cor_wt                   ./= sum(bulk_cor_wt)
        else
            zrc_wt, bulk_cor_wt = nothing, nothing
        end

        liq_wt_norm = 1.0
    else
        print("unrecognized case!\n")
        Cliq, Cmin, ph_TE, ph_wt_norm, liq_wt_norm, Cliq_Zr, zrc_wt, bulk_cor_wt = nothing, nothing, nothing, nothing, nothing, nothing, nothing, nothing
    end

    out_TE = out_tepm(Cliq, Cmin, ph_TE, ph_wt_norm, liq_wt_norm, Cliq_Zr, Sat_zr_liq, zrc_wt, bulk_cor_wt)

    return out_TE
end
