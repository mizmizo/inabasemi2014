#!usr/bin/env roseus

(ros::roseus "mopping")

(load "package://hrpsys_ros_bridge_tutorials/euslisp/hrp2w-interface.l")
(hrp2w-init)
(objects *hrp2w*)

(setq *tfl* (instance ros::transform-listener :init))

(defun init ()
  (send *hrp2w* :reset-pose)
  (send *hrp2w* :head :neck-p :joint-angle 30)
  (send *hrp2w* :head :look-at (send *hrp2w* :rarm :end-coords :pos))
;  (send *ri* :angle-vector (send *hrp2w* :angle-vector) 5000)
)


(defun catch1 ()
                                        ;targetting                                               
                                        ;rarm 
  (setq *torso-co* (send (car (send *hrp2w* :torso)) :copy-worldcoords))
  (send *tfl* :wait-for-transform "CHEST_LINK0"
        "/camera_remote/depth_registered/cluster_decomposeroutput00"
        (ros::time 0) 3)
  (setq *tarr* (send *tfl* :lookup-transform "CHEST_LINK0"
        "/camera_remote/depth_registered/cluster_decomposeroutput00"
	(ros::time 0)))
  (setq *torso-co-copy* (send *torso-co* :copy-worldcoords))
  (setq *tarr-copy* (send *tarr* :copy-worldcoords))
  (setq *ik-rtarget* (send *torso-co* :transform *tarr*))
  (setq *ik-rtarget-pre* (send *torso-co-copy* :transform *tarr-copy*))
  (setq *ik-rtarget-rtn* (send *torso-co-copy* :transform *tarr-copy*))
  (send *ik-rtarget-pre* :translate #f(-150 -70 0) :world)
  (setq *rarm-end* (send *hrp2w* :rarm :end-coords :copy-worldcoords))
  (send *rarm-end* :locate (send *ik-rtarget-pre* :pos) :world)
  (send *hrp2w* :rarm :inverse-kinematics *rarm-end* :rotation-axis nil
	:debug-view t :torso t :link-list (send *hrp2w* :link-list (send
    *hrp2w* :rarm :end-coords :parent) (car (send *hrp2w* :torso :links))))
  (send *hrp2w* :rarm :thumb-r :joint-angle 45)
  (send *hrp2w* :head :look-at (send *hrp2w* :rarm :end-coords :pos))
;  (send *ri* :angle-vector (send *hrp2w* :angle-vector) 5000)
;  (send *ri* :wait-interpolation)
)

(defun catch2 ()
  (setq *rarm-end* (send *hrp2w* :rarm :end-coords :copy-worldcoords))
  (send *rarm-end* :locate (send *ik-rtarget* :pos) :world)
  (send *hrp2w* :rarm :inverse-kinematics *rarm-end* :rotation-axis nil
   :debug-view t :torso t :link-list (send *hrp2w* :link-list (send
   *hrp2w* :rarm :end-coords :parent) (car (send *hrp2w* :torso :links))))
  (send *hrp2w* :rarm :thumb-r :joint-angle 45)
;  (send *ri* :angle-vector (send *hrp2w* :angle-vector) 5000)
;  (send *ri* :wait-interpolation)
;  (hrp2w-start-grasp :rarm)
)

;one hand                                                                                            
(defun catch3 ()
  (setq *rarm-end* (send *hrp2w* :rarm :end-coords :copy-worldcoords))
  (send *rarm-end* :translate #f(-50 -50 200) :world)
  (send *hrp2w* :rarm :inverse-kinematics *rarm-end* :rotation-axis nil
   :debug-view t :torso t :link-list (send *hrp2w* :link-list (send
   *hrp2w* :rarm :end-coords :parent) (car (send *hrp2w* :torso :links))))
;  (send *ri* :angle-vector (send *hrp2w* :angle-vector) 5000)
)
(defun catch4 ()
					;rarm up                                                    
  (send *hrp2w* :rarm :angle-vector #f(-40 -18 60 -64 -35 40 -14 0))
  (send *hrp2w* :torso :angle-vector #f(0 0))
;  (send *ri* :angle-vector (send *hrp2w* :angle-vector) 5000)
;  (send *ri* :wait-interpolation)
)
(defun catch5 ()
					;larm left sweep
  (send *hrp2w* :larm :angle-vector #f(-55 35 -51 -92 80 -26 24 -45))
;  (send *ri* :angle-vector (send *hrp2w* :angle-vector) 5000)
;  (send *ri* :wait-interpolation)
)

(defun catch6 ()
  (send *hrp2w* :larm :angle-vector #f(-72 24 -60 -87 80 -24 13 -45))
;  (send *ri* :angle-vector (send *hrp2w* :angle-vector) 5000)
;  (send *ri* :wait-interpolation)
;  (send *ri* :start-impedance :larm)
;  (hrp2w-start-grasp :larm)
)


(defun sweepready ()
                                        ;ready                                                       
  (send *hrp2w* :rarm :angle-vector #f(-40 -13 72 -46 -30 35 -29 0))
  (send *hrp2w* :larm :angle-vector #f(-60 26 -60 -90 65 -24 13 0))
;  (send *ri* :angle-vector (send *hrp2w* :angle-vector) 5000)
;  (send *ri* :wait-interpolation)
)

(defun sweepleft ()
                                        ;left sweep                                                  
  (send *hrp2w* :larm :angle-vector #f(-55 35 -51 -92 80 -26 24 0))
  (send *hrp2w* :rarm :angle-vector #f(-45 5 72 -26 -25 35 -30 0))
  (send *hrp2w* :torso :angle-vector #f(15 0))
;  (send *ri* :angle-vector (send *hrp2w* :angle-vector) 5000)
;  (send *ri* :wait-interpolation)
)

(defun sweepright ()
                                        ;ready                                                       
  (send *hrp2w* :rarm :angle-vector #f(-28 -31 51 -60 -25 28 -29 0))
  (send *hrp2w* :larm :angle-vector #f(-75 -3 -70 -60 65 -24 13 0))
  (send *hrp2w* :torso :angle-vector #f(-15 0))
;  (send *ri* :angle-vector (send *hrp2w* :angle-vector) 5000)
;  (send *ri* :wait-interpolation)
)

(defun sweepup ()
                                        ;up                                                          
  (send *hrp2w* :larm :angle-vector #f(-72 24 -60 -87 80 -24 13 0))
  (send *hrp2w* :rarm :angle-vector #f(-40 -18 60 -64 -35 40 -14 0))
;  (send *ri* :angle-vector (send *hrp2w* :angle-vector) 5000)
;  (send *ri* :wait-interpolation)
)


(defun return_mop ()
                                        ;ready                                                       
  (send *hrp2w* :rarm :angle-vector #f(-40 -13 72 -46 -30 35 -29 15))
  (send *hrp2w* :larm :angle-vector #f(-60 26 -60 -90 65 -24 13 -15))
  (send *ri* :angle-vector (send *hrp2w* :angle-vector) 5000)
  (send *ri* :wait-interpolation)
  (hrp2w-stop-grasp :larm)
  (send *hrp2w* :larm :thumb-r :joint-angle -45)
  (send *ri* :angle-vector (send *hrp2w* :angle-vector) 3000)
  (send *ri* :wait-interpolation)
  (send *hrp2w* :larm :angle-vector #f(-55 35 -51 -92 80 -26 24 -45))
  (send *ri* :angle-vector (send *hrp2w* :angle-vector) 3000)
  (send *ri* :wait-interpolation)
  (send *ri* :stop-impedance :larm)
  (setq *rarm-end* (send *hrp2w* :rarm :end-coords :copy-worldcoords))
  (send *rarm-end* :locate (send *ik-rtarget-rtn* :pos) :world)
  (send *hrp2w* :rarm :inverse-kinematics *rarm-end* :rotation-axis nil
   :debug-view t :torso t :link-list (send *hrp2w* :link-list (send
   *hrp2w* :rarm :end-coords :parent) (car (send *hrp2w* :torso :links))))
  (send *ri* :angle-vector (send *hrp2w* :angle-vector) 5000)
  (send *ri* :wait-interpolation)
  (hrp2w-stop-grasp :rarm)
  ;;  (send *hrp2w* :reset-pose)
  ;;  (send *hrp2w* :angle-vector (send *hrp2w* :angle-vector) 5000)
  ;;  (send *ri* :wait-interpolation)
)

(defun posing ()
  (send *ri* :angle-vector (send *hrp2w* :angle-vector) 5000)
)

1