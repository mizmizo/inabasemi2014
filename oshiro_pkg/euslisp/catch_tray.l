#!/usr/bin/env roseus

(load "package://hrpsys_ros_bridge_tutorials/euslisp/hrp2w-interface.l")
;(hrp2w-init)
(hrp2w-init :sim t)
(objects *hrp2w*)

(ros::roseus-add-msgs "jsk_pcl_ros")
(ros::roseus "catch_tray")

(setq *tfl* (instance ros::transform-listener :init))

(setq *torso-co* (send (car (send *hrp2w* :torso)) :copy-worldcoords))
;; トルソリンクの一番最初の世界座標系での座標をコピー

;;当て決めで手を動かす.
(defun catch_tray nil
  (send *hrp2w* :angle-vector #f(0.0 30.0 0.0 40.0 -49.3179 -14.353 19.4521 -62.9683 -22.2948 0.53918 53.9622 60.0 -49.3179 14.353 -19.4521 -62.9683 22.2948 -0.53919 53.9622 -60.0))
;(send *ri* :angle-vector (send *hrp2w* :angle-vector) 5000)
  )
;;シミュレーション用(catch_trayの位置にtray_posをおく)
(defun sim_pos nil
  (catch_tray)
  (setq *rtray_pos* (send *hrp2w* :rarm :end-coords :copy-worldcoords))

  (setq *ltray_pos* (send *hrp2w* :larm :end-coords :copy-worldcoords))
  (send *hrp2w* :reset-manip-pose)
  )
(defun recog_1marker nil
  (send *tfl* :wait-for-transform
	"CHEST_LINK0" "/camera_remote/depth_registered/cluster_decomposeroutput00" (ros::time 0) 3)
  (setq *target-co*
	(send *tfl* :lookup-transform
	      "CHEST_LINK0" "/camera_remote/depth_registered/cluster_decomposeroutput00" (ros::time 0)))
  (setq *ik-target* (send *torso-co* :transform *target-co*))
  ;; トルソから計算し直すことでeus世界の世界座標系に変換
  (setq *rtray_pos* (send *hrp2w* :rarm :end-coords :copy-worldcoords))
  ;; 右手の先の角度を動かしたくないので，一度今の角度を保持するため座標ごとコピー
  (send *rtray_pos* :locate (send *ik-target* :pos) :world)
  ;; コピーした右手座標の位置だけを認識したものにすげ替える

  (setq *ltray_pos* (send *hrp2w* :larm :end-coords :copy-worldcoords))
  ;;左手の先の角度を動かしたくないので，一度今の角度を保持するため座標ごとコピー
  (send *ltray_pos* :locate (send *ik-target* :pos) :world)
  ;;""右手""の位置をコピー
  (send *ltray_pos* :translate (float-vector 0 500 0))
  ;;trayの幅から逆算して平行移動
  )

;;掴む前のポーズ.
(defun pre_pose nil
  (send *hrp2w* :angle-vector #f(0.0 15.0 0.0 40.0 -56.5395 -60.0223 49.4609 -112.253 -68.1949 -32.7942 69.9981 80.0 -45.0344 55.8813 -34.5312 -112.616 64.4653 34.6465 73.182 -80.0))
  ;(send *ri* :angle-vector (send *hrp2w* :angle-vector) 5000)
  )

(defun via nil
  ;;右手の経由
  (setq *rvia* (send *hrp2w* :rarm :end-coords :copy-worldcoords))
  (send *rvia* :locate (send *rtray_pos* :pos) :world)
  (send *rvia* :translate (float-vector -120 0 0))
  (send *hrp2w* :rarm :inverse-kinematics *rvia* :rotation-axis t :torso t)
  ;;左手の経由
  (setq *lvia* (send *hrp2w* :larm :end-coords :copy-worldcoords))
  (send *lvia* :locate (send *ltray_pos* :pos) :world)
  (send *lvia* :translate (float-vector -120 0 0))
  (send *hrp2w* :larm :inverse-kinematics *lvia* :rotation-axis t :torso t)
  ;(send *ri* :angle-vector (send *hrp2w* :angle-vector) 5000)
  )

(defun go_tray_pos nil
  (send *hrp2w* :rarm :inverse-kinematics *rtray_pos* :rotation-axis t :torso t)
  (send *hrp2w* :larm :inverse-kinematics *ltray_pos* :rotation-axis t :torso t)
  ;(send *ri* :angle-vector (send *hrp2w* :angle-vector) 5000)
  ;;トレイの持ち手との位置関係は要修正
  )

(defun catch nil
  (send *ri* :start-impedance :larm)
  (hrp2w-start-grasp :rarm)
  (hrp2w-start-grasp :larm)
  )

;;掴んだ後トレイを持ち上げる.
(defun up_tray nil
  (setq *rarm-end* (send *hrp2w* :rarm :end-coords :copy-worldcoords))
  (setq *larm-end* (send *hrp2w* :larm :end-coords :copy-worldcoords))
  (send *rarm-end* :translate (float-vector -200 0 -100))
  (send *larm-end* :translate (float-vector -200 0 -100))
  (send *hrp2w* :torso :waist-y :joint-angle 0)
  (send *hrp2w* :rarm :inverse-kinematics *rarm-end* :rotation-axis t :torso t)
  (send *hrp2w* :larm :inverse-kinematics *larm-end* :rotation-axis t :torso t)
   ;;持ち上げた姿勢を決め打ちに変更したい
  ;(send *ri* :angle-vector (send *hrp2w* :angle-vector) 5000)
  )

;;持ち上げたトレイを下げる関数の実装が必要.

(defun release nil
  (hrp2w-stop-grasp :rarm :angle -10)
  (hrp2w-stop-grasp :larm :angle 10)
  (send *ri* :stop-impedance :larm)
 )


;;(send *rarm-end* :locate (send *rtarget* :pos) :world)
;;(send *larm-end* :locate (send *ltarget* :pos) :world)

;;持つときのangle-vector
;;#f(0.0 30.0 0.0 40.0 -48.0279 -15.1736 18.9004 -66.7682 -22.5412 -0.027868 56.2728 60.0 -44.8755 12.1764 -11.4703 -73.9615 22.1978 2.31731 61.1763 -60.0)

;;持ち上げたときのangle-vector
;#f(0.0 0.0 0.0 40.0 -23.1573 -58.2268 49.3678 -106.791 -63.9827 -28.3061 52.4675 80.0 -16.0814 54.2009 -39.2989 -106.798 57.3088 25.5472 57.9657 -80.0)

;trayのpos
;(setq *tray* (make-cube 300 500 30))
;#f(550.0 0.0 600.0)