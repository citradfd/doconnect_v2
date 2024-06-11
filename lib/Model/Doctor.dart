class Docter {
  int? id;
  String? nama;
  String? fakultas;
  String? rumahsakit;
  int? patiens;
  String? experiences;
  String? category;
  String? about;
  String? foto;

  Docter(
      {this.id,
      this.nama,
      this.fakultas,
      this.rumahsakit,
      this.patiens,
      this.experiences,
      this.category,
      this.about,
      this.foto});

  Docter.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    nama = json['nama'];
    fakultas = json['fakultas'];
    rumahsakit = json['rumahsakit'];
    patiens = json['patiens'];
    experiences = json['experiences'];
    category = json['category'];
    about = json['about'];
    foto = json['foto'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['nama'] = this.nama;
    data['fakultas'] = this.fakultas;
    data['rumahsakit'] = this.rumahsakit;
    data['patiens'] = this.patiens;
    data['experiences'] = this.experiences;
    data['category'] = this.category;
    data['about'] = this.about;
    data['foto'] = this.foto;
    return data;
  }
}
