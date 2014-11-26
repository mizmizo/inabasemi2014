#!usr/bin/env roseus

(ros::roseus "mopping")

(load "package://hrpsys_ros_bridge_tutorials/euslisp/hrp2w-interface.l")
(hrps2-init)
(objects *hrp2w*)

(setq *tfl* (instance ros::transform-listener :init))

(defun init ()
  (send *hrp2w* :reset-pose)
  (send *ri* :angle-vector (send *hrp2w* :angle-vector) 5000)
)


(defun catch ()
                                        ;targetting                                               
                                        ;rarm 
  (setq *torso-co* (send (car (send *hrp2w* :torso)) :copy-worldcoords))
  (send *tfl* :wait-for-transform "CHEST_LINK0"
        "/camera_remote/depth_registered/cluster_decomposeroutput00"
        (ros::time 0) 3)
  (send *tarr* (send *tfl* :lookup-transform "CHEST_LINK0"
        "/camera_remote/depth_registered/cluster_decomposeroutput00"
	(ros::time 0)))
  (setq *ik-rtarget* (send *torso-co* :transform *tarr*))
  (setq *ik-rtarget-pre* :locate (send *ik-rtarget* :pos) :world)
  (send *ik-rtarget-pre* :translate #f(-100 0 0))
  (setq *rarm-end* (send *hrp2w* :rarm :end-coords :copy-worldcoords))
  (send *rarm-end* :locate (send *ik-rtarget-pre* :pos) :world)
  (send *hrp2w* :rarm :inverse-kinematics *rarm-end* :rotation-axis nil
	:debug-view t :torso t :link-list (send *hrp2w* :link-list (send
    *hrp2w* :rarm :end-coords :parent) (car (send *hrp2w* :torso :links))))
  (send *hrp2w* :rarm :thumb-r :joint-angle 45)
  (send *ri* :angle-vector (send *hrp2w* :angle-vector) 5000)
  (send *ri* :wait-interpolation)

  (setq *rarm-end* (send *hrp2w* :rarm :end-coords :copy-worldcoords))
  (send *rarm-end* :locate (send *ik-rtarget* :pos) :world)
  (send *hrp2w* :rarm :inverse-kinematics *rarm-end* :rotation-axis nil
   :debug-view t :torso t :link-list (send *hrp2w* :link-list (send
   *hrp2w* :rarm :end-coords :parent) (car (send *hrp2* :torso :links))))
  (send *hrp2w* :rarm :thumb-r :joint-angle 45)
  (send *ri* :angle-vector (send *hrp2w* :angle-vector) 5000)
  (send *ri* :wait-interpolation)
  (hrp2w-start-grasp :rarm)

;one hand                                                                                            
  (setq *rarm-end* (send *hrp2w* :rarm :end-coords :copy-worldcoords))
  (send *rarm-end* :locate (send *ik-rtarget* :pos) :world)
  (send *hrp2w* :rarm :inverse-kinematics *rarm-end* :rotation-axis nil
   :debug-view t :torso t :link-list (send *hrp2w* :link-list (send
   *hrp2w* :rarm :end-coords :parent) (car (send *hrp2* :torso :links))))
  (send *ri* :angle-vector (send *hrp2w* :anlge-vector) 5000)
                                        ;up                                                         
  (send *hrp2w* :rarm :angle-vector #f(-40 -18 60 -64 -35 40 -14 15))
  (send *ri* :angle-vector (send *hrp2w* :angle-vector) 5000)
  (send *ri* :wait-interpolation)
  (send *hrp2w* :larm :angle-vector #f(-72 24 -60 -87 80 -24 13 -45))
  (send *ri* :angle-vector (send *hrp2w* :angle-vector) 5000)
  (send *ri* :wait-interpolation)
  (send *hrp2w* :start-impedance :larm)
  (hrp2w-start-grasp :larm)
)


(defun sweep ()
                                        ;ready                                                       
  (send *hrp2w* :rarm :angle-vector #f(-40 -13 72 -46 -30 35 -29 15))
  (send *hrp2w* :larm :angle-vector #f(-60 26 -60 -90 65 -24 13 -15))
  (send *ri* :angle-vector (send *hrp2w* :angle-vector) 5000)
  (send *ri* :wait-interpolation)
                                        ;left sweep                                                  
  (send *hrp2w* :rarm :angle-vector #f(-55 35 -51 -92 80 -26 24 -15))
  (send *hrp2w* :larm :angle-vector #f(-45 5 72 -26 -25 35 -30 15))
  (send *hrp2w* :torso :angle-vector #f(15 0))
  (send *ri* :angle-vector (send *hrp2w* :angle-vector) 5000)
  (send *ri* :wait-interpolation)
                                        ;ready                                                       
  (send *hrp2w* :rarm :angle-vector #f(-40 -13 72 -46 -30 35 -29 15))
  (send *hrp2w* :larm :angle-vector #f(-60 26 -60 -90 65 -24 13 -15))
  (send *ri* :angle-vector (send *hrp2w* :angle-vector) 5000)
  (send *ri* :wait-interpolation)
                                        ;up                                                          
  (send *hrp2w* :larm :angle-vector #f(-72 24 -60 -87 80 -24 13 -15))
  (send *hrp2w* :rarm :angle-vector #f(-40 -18 60 -64 -35 40 -14 15))
  (send *ri* :angle-vector (send *hrp2w* :angle-vector) 5000)
  (send *ri* :wait-interpolation)
)


(defun return ()
                                        ;ready                                                       
  (send *hrp2w* :rarm :angle-vector #f(-40 -13 72 -46 -30 35 -29 15))
  (send *hrp2w* :larm :angle-vector #f(-60 26 -60 -90 65 -24 13 -15))
  (send *ri* :angle-vector (send *hrp2w* :angle-vector) 5000)
  (send *ri* :wait-interpolation)
  (hrp2w-stop-grasp :larm)
  (hrp2w-stop-grasp :rarm)
  (send *ri* :stop-impedance :rarm)
  (send *hrp2w* :reset-pose)
  (send *hrp2w* :angle-vector (send *hrp2w* :angle-vector) 5000)
  (send *ri* :wait-interpolation)
)


