#!/usr/bin/env roseus

(ros::roseus "umbrella-catch")
(ros::roseus-add-msgs "jsk_pcl_ros")
(load "package://hrpsys_ros_bridge_tutorials/euslisp/hrp2w-interface.l")
(hrp2w-init)
(setq *umb-pos* nil)
(setq *obj-tf* nil)
(setq *lruse* nil)
(setq *lrsign* nil)

(defun box-callback (msg)
  (setq boxes (send msg :boxes))
  (when boxes
    (setq maxindex 0)
    (setq maxv 0)
    (setq count 0)
    (dolist (box boxes)
      (setq x (send box :dimensions :x))
      (setq y (send box :dimensions :y))
      (setq z (send box :dimensions :z))
      (if (> (* x y z) maxv)
	  (progn
	    (setq maxindex count)
	    (setq maxv (* x y z))))
      (setq count (+ count 1)))
    (setq *obj-tf* (format nil "/camera_remote/depth_registered/cluster_decomposeroutput~0,2d" maxindex))))

(ros::subscribe "/camera_remote/depth_registered/cluster_decomposer/boxes" jsk_pcl_ros::BoundingBoxArray #'box-callback)

(objects (list *hrp2w*))

(defun detect ()
  (setq *obj-tf* nil)
  (ros::spin-once)
  (when *obj-tf*
    (progn
      (setq *tfl* (instance ros::transform-listener :init))
      (when (send *tfl* :wait-for-transform "CHEST_LINK0" *obj-tf* (ros::time 0) 3)
	(progn
	  (setq *torso-co* (send (car (send *hrp2w* :torso)) :copy-worldcoords))
	  (setq *target-co* (send *tfl* :lookup-transform "CHEST_LINK0" *obj-tf* (ros::time 0)))
	  ;; TFで認識されたものの一番最初の場所を，CHEST_LINK0から見た相対座標を持ってくる．
	  (setq *umb-pos* (send *torso-co* :transform *target-co*))
	  (if (> (elt (send *umb-pos* :pos) 1) 0)
	      (progn
		(setq *lruse* ':larm)
		(setq *lrsign* 1)
		(print "use larm"))
	    (progn
	      (setq *lruse* ':rarm)
	      (setq *lrsign* -1)
	      (print "use rarm")))
	  (setq *umb-dest-pos* (send *hrp2w* *lruse* :end-coords :copy-worldcoords))
	  (send *umb-dest-pos* :locate (send *umb-pos* :pos) :world)
	  (objects (list *hrp2w* *umb-pos* *umb-dest-pos*)))))))

(defun reset ()
  (send *hrp2w* :reset-pose)
  (send *hrp2w* :head :neck-p :joint-angle 30.0)
  (send *ri* :angle-vector (send *hrp2w* :angle-vector) 5000)
  (send *ri* :wait-interpolation)
)

(defun ready ()
  (setq *dest* (send *umb-dest-pos* :copy-worldcoords))
  (send *dest* :translate (float-vector -100 0 0))
  (send *hrp2w* *lruse* :inverse-kinematics *dest* :debug-view t :link-list (send *hrp2w* :link-list (send *hrp2w* *lruse* :end-coords :parent)))
  (send *ri* :angle-vector (send *hrp2w* :angle-vector) 3000)
  (send *ri* :wait-interpolation)

  (hrp2w-stop-grasp *lruse*)
  (send *ri* :wait-interpolation)

  (setq *dest* (send *umb-dest-pos* :copy-worldcoords))
  (send *dest* :translate (float-vector 0 (* 20 *lrsign*) 0))
  (send *hrp2w* *lruse* :inverse-kinematics *dest* :debug-view t :link-list (send *hrp2w* :link-list (send *hrp2w* *lruse* :end-coords :parent)))
  (send *ri* :angle-vector (send *hrp2w* :angle-vector) 5000)
  (send *ri* :wait-interpolation)
)

(defun catch ()
  (hrp2w-start-grasp *lruse* :angle (* 15 *lrsign*))
)

(defun up ()
  (setq *dest* (send *umb-dest-pos* :copy-worldcoords))
  (send *dest* :translate (float-vector 0 0 250))
  (send *hrp2w* *lruse* :inverse-kinematics *dest* :debug-view t :link-list (send *hrp2w* :link-list (send *hrp2w* *lruse* :end-coords :parent)))
  (send *ri* :angle-vector (send *hrp2w* :angle-vector) 5000)
  (send *ri* :wait-interpolation)

  (setq *dest* (send *umb-dest-pos* :copy-worldcoords))
  (send *dest* :translate (float-vector 0 0 500))
  (send *hrp2w* *lruse* :inverse-kinematics *dest* :debug-view t :link-list (send *hrp2w* :link-list (send *hrp2w* *lruse* :end-coords :parent)))
  (send *ri* :angle-vector (send *hrp2w* :angle-vector) 5000)
  (send *ri* :wait-interpolation)
)

(defun back ()
  (setq *dest* (send *umb-dest-pos* :copy-worldcoords))
  (send *dest* :translate (float-vector -200 0 500))
  (send *hrp2w* *lruse* :inverse-kinematics *dest* :debug-view t :link-list (send *hrp2w* :link-list (send *hrp2w* *lruse* :end-coords :parent)))
  (send *ri* :angle-vector (send *hrp2w* :angle-vector) 5000)
  (send *ri* :wait-interpolation)

  (setq *thumb* (send *hrp2w* *lruse* :thumb-r :joint-angle))
  (send *hrp2w* :reset-pose)
  (send *hrp2w* *lruse* :thumb-r :joint-angle *thumb*)
  (send *ri* :angle-vector (send *hrp2w* :angle-vector) 5000)
  (send *ri* :wait-interpolation)
)
