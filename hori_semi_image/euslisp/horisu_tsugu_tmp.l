#!/usr/bin/env roseus

(load "package://hrpsys_ros_bridge_tutorials/euslisp/hrp2w-interface.l")
(hrp2w-init)
(objects (list *hrp2w*))
;;(ros::roseus "horisu_tsugu")


(defun kamae ()

  (send *hrp2w* :reset-pose)
  (send *irt-viewer* :draw-objects)
  (send *ri* :angle-vector (send *hrp2w* :angle-vector) 5000)
  (send *ri* :wait-interpolation)  

  ;;
  (setq *larm-end* (send *hrp2w* :larm :endcoords :copy-worldcoords))
  (setq *rarm-end* (send *hrp2w* :rarm :endcoords :copy-worldcoords))
  
  (send *larm-end* (send *larm-end* :translate #f(-100 -200 0)))
  (send *larm-end* :rpy -45 0 0)

  (send *hrp2w* :larm :inverse-kinematics *larm-end* :rotation-axis :x
	:debug-view t :torso t 
	:link-list (cdr (cdr (send *hrp2w* :link-list (send *hrp2w* :larm :end-coords :parent) (car (send *hrp2w* :torso :links))))))

  (send *hrp2w* :head :look-at (send *hrp2w* :larm :end-coords :pos))

  (send *irt-viewer* :draw-objects)
  (send *ri* :angle-vector (send *hrp2w* :angle-vector) 5000)
  (send *ri* :wait-interpolation)
  ;;
  (setq *rarm-end* (send *larm-end* :copy-worldcoords))
  (send *rarm-end* :locate #f(0 -150 0) :world)
  (send *rarm-end* :rpy 45 0 0)

  (send *hrp2w* :rarm :inverse-kinematics *rarm-end* :rotation-axis :x
	:debug-view t :torso t 
	:link-list (cdr (cdr (send *hrp2w* :link-list (send *hrp2w* :rarm :end-coords :parent) (car (send *hrp2w* :torso :links))))))
  (send *ri* :angle-vector (send *hrp2w* :angle-vector) 5000)
  (send *ri* :wait-interpolation)
)

(defun sosogi ()

  (setq *cap-end* (send *hrp2w* :larm :end-coords :copy-worldcoords))
  (send *cap-end* :locate #f(0 0 100) :world)

  (send *rarm-end* :pos (send *hrp2w* :larm :end-coords :worldpos))
  (send *rarm-end* :locate (float-vector 0 (* (- 100) (sin (deg2rad 45))) (* (- 100) (cos (deg2rad 45)))) :world)
  (send *rarm-end* :rotate -45 :x :world)
   
  (send *hrp2w* :rarm :inverse-kinematics *rarm-end* :rotation-axis :x
	:debug-view t :torso t 
	:link-list (cdr (cdr (send *hrp2w* :link-list (send *hrp2w* :rarm :end-coords :parent) (car (send *hrp2w* :torso :links))))))
  (send *ri* :angle-vector (send *hrp2w* :angle-vector) 5000)
  (send *ri* :wait-interpolation)
)



(defun tsukamu ()


	      (setq *rarm-end* (send *hrp2w* :rarm :end-coords :copy-worldcoords))

	      (send *rarm-end** :translate #f(150 200 -200) :world)

	      (send *hrp2w* :rarm :inverse-kinematics *rarm-end* :rotation-axis :x
		    :debug-view t :torso t :link-list (send *hrp2w* :link-list (send
									    *hrp2w* :rarm :end-coords :parent) (car (send *hrp2w* :torso :links))))

	      (send *irtviewer* :draw-objects)
	      (send *ri* :angle-vector (send *hrp2w* :angle-vector) 5000)
	      (send *ri* :wait-interpolation)

	      ;;
	      (send *rarm-end** :translate #f(0 100 0) :world)

	      (send *hrp2w* :rarm :inverse-kinematics *rarm-end* :rotation-axis :x
		    :debug-view t :torso t :link-list (send *hrp2w* :link-list (send
									    *hrp2w* :rarm :end-coords :parent) (car (send *hrp2w* :torso :links))))

	      (send *irtviewer* :draw-objects)
	      (send *ri* :angle-vector (send *hrp2w* :angle-vector) 5000)
	      (send *ri* :wait-interpolation)
)