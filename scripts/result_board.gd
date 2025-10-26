extends Control

@onready var label_akurasi = $LabelAkurasi
@onready var label_score = $LabelScore
@onready var label_time = $LabelTime

func set_result(akurasi: float, score: int, waktu: int):
	label_akurasi.text = "Akurasi: " + str(round(akurasi)) + "%"
	label_score.text = "Skor: " + str(score) + " / 5"
	label_time.text = "Waktu: " + str(waktu) + " detik"

#func _on_button_ok_pressed():
	#emit_signal("ok_pressed")
