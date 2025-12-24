import SwiftUI

// تعريف نموذج البيانات
struct User: Identifiable {
    let id = UUID()
    let name: String
    let email: String
    let phone: String
    let department: String
}

// التطبيق الرئيسي
@main
struct SimpleTableApp: App {
    var body: some Scene {
        WindowGroup {
            UsersListView()
        }
    }
}

// الشاشة الرئيسية
struct UsersListView: View {
    @State private var users = [
        User(name: "أحمد محمد", email: "ahmed@company.com", phone: "0501111111", department: "تطوير البرمجيات"),
        User(name: "سارة علي", email: "sara@company.com", phone: "0502222222", department: "التصميم"),
        User(name: "خالد حسن", email: "khaled@company.com", phone: "0503333333", department: "المبيعات"),
        User(name: "فاطمة عمر", email: "fatima@company.com", phone: "0504444444", department: "الدعم الفني"),
        User(name: "محمد سعيد", email: "mohammed@company.com", phone: "0505555555", department: "التسويق"),
        User(name: "نورة عبدالله", email: "noura@company.com", phone: "0506666666", department: "الموارد البشرية"),
        User(name: "يوسف أحمد", email: "yousef@company.com", phone: "0507777777", department: "المالية"),
        User(name: "لينا خالد", email: "lina@company.com", phone: "0508888888", department: "الجودة"),
        User(name: "عمر محمد", email: "omar@company.com", phone: "0509999999", department: "التطوير"),
        User(name: "هدى سليمان", email: "huda@company.com", phone: "0500000000", department: "الإدارة")
    ]
    
    @State private var showingAddUser = false
    @State private var searchText = ""
    
    var filteredUsers: [User] {
        if searchText.isEmpty {
            return users
        }
        return users.filter { user in
            user.name.localizedCaseInsensitiveContains(searchText) ||
            user.email.localizedCaseInsensitiveContains(searchText) ||
            user.department.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                if users.isEmpty {
                    emptyStateView
                } else {
                    usersListView
                }
            }
            .navigationTitle("الموظفون")
            .navigationBarTitleDisplayMode(.large)
            .searchable(text: $searchText, prompt: "ابحث عن موظف...")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddUser = true }) {
                        Image(systemName: "plus")
                            .font(.headline)
                    }
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    EditButton()
                }
            }
            .sheet(isPresented: $showingAddUser) {
                AddUserView(users: $users)
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "person.3.fill")
                .font(.system(size: 70))
                .foregroundColor(.blue.opacity(0.3))
            
            Text("لا يوجد موظفين")
                .font(.title2)
                .foregroundColor(.secondary)
            
            Text("اضغط على + لإضافة موظف جديد")
                .font(.body)
                .foregroundColor(.gray)
        }
        .padding()
    }
    
    private var usersListView: some View {
        List {
            ForEach(filteredUsers) { user in
                NavigationLink(destination: UserDetailView(user: user)) {
                    UserRowView(user: user)
                }
            }
            .onDelete(perform: deleteUser)
            .onMove(perform: moveUser)
        }
        .listStyle(PlainListStyle())
    }
    
    private func deleteUser(at offsets: IndexSet) {
        users.remove(atOffsets: offsets)
    }
    
    private func moveUser(from source: IndexSet, to destination: Int) {
        users.move(fromOffsets: source, toOffset: destination)
    }
}

// صف المستخدم
struct UserRowView: View {
    let user: User
    
    var body: some View {
        HStack(spacing: 15) {
            // صورة رمزية
            ZStack {
                Circle()
                    .fill(avatarColor(for: user.name))
                    .frame(width: 45, height: 45)
                
                Text(initials(for: user.name))
                    .font(.headline)
                    .foregroundColor(.white)
            }
            
            // معلومات المستخدم
            VStack(alignment: .leading, spacing: 4) {
                Text(user.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(user.email)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                HStack {
                    Image(systemName: "building.2.fill")
                        .font(.caption2)
                    Text(user.department)
                        .font(.caption)
                        .foregroundColor(.blue)
                }
            }
            
            Spacer()
            
            // رمز الهاتف
            HStack(spacing: 5) {
                Image(systemName: "phone.fill")
                    .font(.caption)
                    .foregroundColor(.green)
                
                Text(user.phone.suffix(4))
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding(.vertical, 5)
    }
    
    private func initials(for name: String) -> String {
        let components = name.split(separator: " ")
        if components.count >= 2 {
            return String(components[0].prefix(1) + components[1].prefix(1))
        }
        return String(name.prefix(2))
    }
    
    private func avatarColor(for name: String) -> Color {
        let colors: [Color] = [.blue, .green, .orange, .purple, .red, .pink, .indigo, .teal]
        let index = abs(name.hash) % colors.count
        return colors[index]
    }
}

// شاشة إضافة مستخدم
struct AddUserView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var users: [User]
    
    @State private var name = ""
    @State private var email = ""
    @State private var phone = ""
    @State private var department = "تطوير البرمجيات"
    
    let departments = [
        "تطوير البرمجيات",
        "التصميم",
        "المبيعات",
        "الدعم الفني",
        "التسويق",
        "الموارد البشرية",
        "المالية",
        "الجودة",
        "الإدارة"
    ]
    
    private var isFormValid: Bool {
        !name.isEmpty && !email.isEmpty && !phone.isEmpty
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("المعلومات الشخصية")) {
                    TextField("الاسم الكامل", text: $name)
                    
                    TextField("البريد الإلكتروني", text: $email)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                    
                    TextField("رقم الهاتف", text: $phone)
                        .keyboardType(.phonePad)
                }
                
                Section(header: Text("القسم")) {
                    Picker("اختر القسم", selection: $department) {
                        ForEach(departments, id: \.self) { dept in
                            Text(dept)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
                
                Section {
                    Button(action: addUser) {
                        HStack {
                            Spacer()
                            Text("إضافة الموظف")
                                .fontWeight(.bold)
                            Spacer()
                        }
                    }
                    .disabled(!isFormValid)
                    .foregroundColor(.white)
                    .listRowBackground(isFormValid ? Color.blue : Color.gray)
                }
            }
            .navigationTitle("إضافة موظف")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("إلغاء") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func addUser() {
        let newUser = User(
            name: name,
            email: email,
            phone: phone,
            department: department
        )
        users.append(newUser)
        dismiss()
    }
}

// شاشة تفاصيل المستخدم
struct UserDetailView: View {
    let user: User
    
    var body: some View {
        VStack(spacing: 25) {
            // الصورة الرمزية الكبيرة
            ZStack {
                Circle()
                    .fill(avatarColor(for: user.name))
                    .frame(width: 120, height: 120)
                
                Text(initials(for: user.name))
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(.white)
            }
            .padding(.top, 40)
            
            // معلومات المستخدم
            VStack(spacing: 20) {
                InfoRow(icon: "person.fill", title: "الاسم", value: user.name)
                InfoRow(icon: "envelope.fill", title: "البريد الإلكتروني", value: user.email)
                InfoRow(icon: "phone.fill", title: "الهاتف", value: user.phone)
                InfoRow(icon: "building.2.fill", title: "القسم", value: user.department)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(15)
            .padding(.horizontal)
            
            Spacer()
            
            // أزرار الإجراءات
            HStack(spacing: 20) {
                Button(action: { callNumber(user.phone) }) {
                    ActionButton(icon: "phone.fill", text: "اتصال", color: .green)
                }
                
                Button(action: { sendEmail(user.email) }) {
                    ActionButton(icon: "envelope.fill", text: "بريد", color: .blue)
                }
            }
            .padding(.bottom, 30)
        }
        .navigationTitle("تفاصيل الموظف")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func initials(for name: String) -> String {
        let components = name.split(separator: " ")
        if components.count >= 2 {
            return String(components[0].prefix(1) + components[1].prefix(1))
        }
        return String(name.prefix(2))
    }
    
    private func avatarColor(for name: String) -> Color {
        let colors: [Color] = [.blue, .green, .orange, .purple, .red, .pink, .indigo, .teal]
        let index = abs(name.hash) % colors.count
        return colors[index]
    }
    
    private func callNumber(_ phone: String) {
        let cleanNumber = phone.filter { $0.isNumber }
        if let url = URL(string: "tel://\(cleanNumber)") {
            UIApplication.shared.open(url)
        }
    }
    
    private func sendEmail(_ email: String) {
        if let url = URL(string: "mailto:\(email)") {
            UIApplication.shared.open(url)
        }
    }
}

struct InfoRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 25)
            
            Text(title)
                .font(.subheadline)
                .foregroundColor(.gray)
                .frame(width: 80, alignment: .leading)
            
            Text(value)
                .font(.body)
                .foregroundColor(.primary)
            
            Spacer()
        }
    }
}

struct ActionButton: View {
    let icon: String
    let text: String
    let color: Color
    
    var body: some View {
        VStack {
            Image(systemName: icon)
                .font(.title2)
            Text(text)
                .font(.caption)
        }
        .frame(width: 80, height: 80)
        .foregroundColor(.white)
        .background(color)
        .cornerRadius(15)
    }
}

// معاينة للبيانات
struct UsersListView_Previews: PreviewProvider {
    static var previews: some View {
        UsersListView()
    }
}
