final RegExp Email_Validation = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-{2,4}$]");
final RegExp Password_Validation =
    RegExp(r"^(?=.*\d)(?=.*[a-z])(?=.*[A-Z])(?=.*[a-zA-Z]).{8,}$");
final RegExp Name_Validation =
    RegExp(r"^[\w'\-,.][^0-9_!¡?÷?¿/\\+=@#$%ˆ&*(){}|~<>;:[\]]{2,}$");
final String Place_Holder =
    "https://upload.wikimedia.org/wikipedia/en/b/b1/Portrait_placeholder.png";
