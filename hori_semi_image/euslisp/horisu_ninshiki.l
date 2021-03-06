#!/usr/bin/env roseus

(load "package://hrpsys_ros_bridge_tutorials/euslisp/hrp2w-interface.l")
(hrp2w-init)
(objects *hrp2w*)
(ros::roseus-add-msgs "jsk_pcl_ros")
(setq *boxg* nil)

(defun boxes-callback (msg)
  (setq *boxg* msg))

(ros::roseus "horisu_ninshiki")
(setq *tfl* (instance ros::transform-listener :init))
(ros::subscribe "/camera_remote/depth_registered/cluster_decomposer/boxes" jsk_pcl_ros::BoundingBoxArray #'boxes-callback)




(defun tsukamu ()
  (if *boxg*
      (progn
	(setq volume 0)
	(setq index 0)
	(setq count 0)
	(dolist (box (send *boxg* :boxes))
	  (progn
	    (if (> (setq volume-tmp (* (send box :dimensions :x) (send box :dimensions :y) (send box :dimensions :z))) volume)
		(progn
		  (setq volume volume-tmp)
		  (setq index count))
	      (setq index (+ count 1)))))

	(setq *torso-co* (send (car (send *hrp2w* :torso)) :copy-worldcoords))
	(if (send *tfl* :wait-for-transform "CHEST_LINK0"
		  (format nil "/camera_remote/depth_registered/cluster_decomposeroutput~0,2d" index)
		  (ros::time 0) 3)
	    (progn
	      (setq *target-co* (send *tfl* :lookup-transform "CHEST_LINK0"
				      (format nil "/camera_remote/depth_registered/cluster_decomposeroutput~0,2d" index)
				      (ros::time 0)))


	      (setq *ik-target* (send *torso-co* :transform *target-co*))

	      (setq *rarm-end* (send *hrp2w* :rarm :end-coords :copy-worldcoords))

	      (send *rarm-end* :locate (send *ik-target* :pos) :world)

	      (send *hrp2w* :rarm :inverse-kinematics *rarm-end* :rotation-axis nil
		    :debug-view t :torso t :link-list (send *hrp2w* :link-list (send
									    *hrp2w* :rarm :end-coords :parent) (car (send *hrp2w* :torso :links))))

	      (send *irtviewer* :draw-objects)
					;(send *ri* :angle-vector (send *hrp2w* :angle-vector) 5000)
					;(send *ri* :wait-interpolation)
	      'done)
	  nil))
    nil))

(ros::spin-once)
(tsukamu)

'end