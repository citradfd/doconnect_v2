class Users {
  String? id;
  String? nama;
  String? email;

  String? password;
  String? foto;

  Users(
      {this.id,
      this.nama,
      this.email,

      this.password,
      this.foto});

  Users.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    nama = json['nama'];
    email = json['email'];

    password = json['password'];
    foto = json['foto'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['nama'] = this.nama;
    data['email'] = this.email;

    data['password'] = this.password;
    data['foto'] = this.foto;
    return data;
  }
}
