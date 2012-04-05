#!/bin/bash
echo task mod is $1  item is $2

#./main.rb --task=difference_image --camera="St_Helens_Low_Res"  --control_exp="luminesence_enhance_control1" --control_exp="luminesence_enhance_control2"  --control_exp="luminesence_enhance_control3"  --crater_exp="luminesence_enhance"  --channel="combined"  --where="MOD( id, $1 ) = $2"
#./main.rb --task=thermal_stats --camera="St_Helens_Low_Res" --where="MOD( id, $1 ) = $2"
#./main.rb --task=mean_control_image --camera="St_Helens_Low_Res" --where=" MOD( id , $1 ) = $2 " --control_exp="luminesence_enhance_control1" --control_exp="luminesence_enhance_control2"  --control_exp="luminesence_enhance_control3"  --channel="combined"

#./main.rb --task=process --camera="Klyuchevskoy" --experiment="Initial Histograms" --operation="channels" --area="Full" --where="MOD( id , $1 ) = $2"

#./main.rb --task=process --camera="Klyuchevskoy" --experiment="make_basic_stats" --operation="channels" --area="klui_control_sky" --where=" MOD( id , $1 ) = $2 "
#./main.rb --task=process --camera="Klyuchevskoy" --experiment="make_basic_stats_b" --operation="channels" --area="klui_control_volc_base" --where=" MOD( id , $1 ) = $2 "
#./main.rb --task=mean_control_image --camera="Klyuchevskoy" --control_exp="make_basic_stats" --control_exp="make_basic_stats_c" --channel="all" --where=" MOD( id , $1 ) = $2 " 
#./main.rb --task=difference_image --camera="Klyuchevskoy" --control_exp="make_basic_stats" --control_exp="make_basic_stats_c" --channel="all" --crater_exp="make_basic_stats_b" --where=" MOD( id , $1 ) = $2 "
./main.rb --task=process --camera="St_Helens_Low_Res" --experiment="Initial Histograms" --operation="channels" --area="Full" --where="MOD( id , $1 ) = $2"
#./main.rb --task=process --camera="St_Helens_Low_Res" --experiment="luminesence_enhance" --operation="st_helens_luminesce_enhance" --area="Full" --where="MOD( id , $1 ) = $2"

