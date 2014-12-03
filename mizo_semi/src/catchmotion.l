!/usr/bin/env roseus

(ros::roseus "catchmotion")

(load "package://hrpsys_ros_bridge_tutorials/euslisp/hrp2w-interface.l")
(hrp2w-init)
(objects *hrp2w*)

(setq *tfl* (instance ros::transform-listener :init))

(setq *torso-co* (send (car (send *hrp2w* :torso)) :copy-worldcoords))
(send *tfl* :wait-for-transform "CHEST_LINK0"
"/camera_remote/depth_registered/cluster_decomposeroutput00"
(ros::time 0) 3))
(setq *target-co* (send *tfl* :lookup-transform "CHEST_LINK0"
"/camera_remote/depth_registered/cluster_decomposeroutput00"
(ros::time 0)))
(setq *ik-target* (send *torso-co* :transform *target-co*))
(setq *rarm-end* (send *hrp2w* :rarm :end-coords :copy-worldcoords))
(send *rarm-end* :locate (send *ik-target* :pos) :world)
(send *hrp2w* :rarm :inverse-kinematics *rarm-end* :rotation-axis nil
:debug-view t :torso t :link-list (send *hrp2w* :link-list (send
*hrp2w* :rarm :end-coords :parent) (car (send *hrp2w* :torso :links))))
;;(send *ri* :angle-vector (send *hrp2w* :angle-vector) 3000)                                         
;;(send *ri* :wait-interpolation)


