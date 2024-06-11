class Booking {
  String? id;
  String? date;
  String? time;
  String? idUser;
  String? idDoctor;
  String? status;
  String? createdAt;
  String? idBooking;
  String? nama;
  String? fakultas;
  String? rumahsakit;
  String? patiens;
  String? experiences;
  String? category;
  String? about;
  String? foto;
  String? idCoctor;
  String? namaUser;
  String? fotoUser;

  Booking(
      {this.id,
      this.date,
      this.time,
      this.idUser,
      this.idDoctor,
      this.status,
      this.createdAt,
      this.idBooking,
      this.nama,
      this.fakultas,
      this.rumahsakit,
      this.patiens,
      this.experiences,
      this.category,
      this.about,
      this.foto,
      this.idCoctor,
      this.namaUser,
      this.fotoUser});

  Booking.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    date = json['date'];
    time = json['time'];
    idUser = json['id_user'];
    idDoctor = json['id_doctor'];
    status = json['status'];
    createdAt = json['created_at'];
    idBooking = json['id_booking'];
    nama = json['nama'];
    fakultas = json['fakultas'];
    rumahsakit = json['rumahsakit'];
    patiens = json['patiens']?.toString();
    experiences = json['experiences'];
    category = json['category'];
    about = json['about'];
    foto = json['foto'];
    idCoctor = json['id_coctor'];
    namaUser = json['nama_user'];
    fotoUser = json['foto_user'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['date'] = this.date;
    data['time'] = this.time;
    data['id_user'] = this.idUser;
    data['id_doctor'] = this.idDoctor;
    data['status'] = this.status;
    data['created_at'] = this.createdAt;
    data['id_booking'] = this.idBooking;
    data['nama'] = this.nama;
    data['fakultas'] = this.fakultas;
    data['rumahsakit'] = this.rumahsakit;
    data['patiens'] = this.patiens;
    data['experiences'] = this.experiences;
    data['category'] = this.category;
    data['about'] = this.about;
    data['foto'] = this.foto;
    data['id_coctor'] = this.idCoctor;
    data['nama_user'] = this.namaUser;
    data['foto_user'] = this.fotoUser;
    return data;
  }
}
