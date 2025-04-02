import SwiftUI
import WebKit

struct RegistrationView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showLogin = false
    @State private var emailError: String? = nil
    @State private var phoneError: String? = nil
    @State private var passwordError: String? = nil
    @State private var isLoading = false
    @State private var showSuccessMessage = false
    @State private var animateGradient = false
    
    private func validateFields() -> Bool {
        var isValid = true
        
        let emailPattern = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailPattern)
        if !emailPredicate.evaluate(with: authViewModel.email) {
            emailError = "Please enter a valid email"
            isValid = false
        } else {
            emailError = nil
        }
        
        // Валидация телефона
        if authViewModel.phone.count < 10 {
            phoneError = "Phone number must be at least 10 digits"
            isValid = false
        } else {
            phoneError = nil
        }
        
        // Валидация пароля
        if authViewModel.password.count < 6 {
            passwordError = "Password must be at least 6 characters"
            isValid = false
        } else {
            passwordError = nil
        }
        
        return isValid
    }
    
    var body: some View {
        ZStack {
            // Анимированный градиентный фон
            LinearGradient(
                gradient: Gradient(colors: [Color(hex: "#FF69B4"), Color(hex: "#8A2BE2")]),
                startPoint: animateGradient ? .topLeading : .bottomTrailing,
                endPoint: animateGradient ? .bottomTrailing : .topLeading
            )
            .ignoresSafeArea()
            .onAppear {
                withAnimation(.easeInOut(duration: 5).repeatForever(autoreverses: true)) {
                    animateGradient = true
                }
            }
            
            // Эффект частиц (можно заменить на другой эффект)
            ParticleEffectView()
            
            VStack(spacing: 20) {
                // Заголовок с анимацией
                Text("Create Account")
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(radius: 5)
                    .padding(.top, 60)
                    .scaleEffect(showSuccessMessage ? 0.8 : 1.0)
                    .animation(.spring(response: 0.5, dampingFraction: 0.6), value: showSuccessMessage)
                
                // Поле для email
                CustomTextField(
                    placeholder: "Email",
                    text: $authViewModel.email,
                    icon: "envelope.fill",
                    errorMessage: $emailError
                )
                
                // Поле для телефона
                CustomTextField(
                    placeholder: "Phone",
                    text: $authViewModel.phone,
                    icon: "phone.fill",
                    errorMessage: $phoneError
                )
                
                // Поле для пароля
                CustomSecureField(
                    placeholder: "Password",
                    text: $authViewModel.password,
                    errorMessage: $passwordError
                )
                
                // Сообщение об ошибке от API
                if let errorMessage = authViewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.system(size: 14, design: .rounded))
                        .padding(.horizontal)
                        .padding(.top, 5)
                }
                
                // Сообщение об успешной регистрации
                if showSuccessMessage {
                    Text("Registration Successful! Please login.")
                        .foregroundColor(.green)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .padding(.horizontal)
                        .padding(.top, 5)
                        .transition(.opacity)
                }
                
                // Кнопка регистрации
                Button(action: {
                    if validateFields() {
                        isLoading = true
                        authViewModel.register(email: authViewModel.email, password: authViewModel.password)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            isLoading = false
                            if authViewModel.errorMessage == nil {
                                withAnimation {
                                    showSuccessMessage = true
                                }
                            }
                        }
                    }
                }) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(hex: "#FFD700"))
                            .frame(height: 50)
                            .shadow(radius: 5)
                        
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text("Register")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.horizontal, 40)
                    .scaleEffect(isLoading ? 0.95 : 1.0)
                    .animation(.spring(response: 0.3), value: isLoading)
                }
                .disabled(isLoading)
                .padding(.top, 20)
                
                // Кнопка перехода на логин
                Button(action: {
                    withAnimation(.easeInOut) {
                        showLogin = true
                    }
                }) {
                    Text("Already have an account? Login")
                        .font(.system(size: 16, design: .rounded))
                        .foregroundColor(.white.opacity(0.8))
                        .underline()
                }
                .padding(.top, 10)
                
                Button(action: {
                    authViewModel.register(email: "guest_\(UUID().uuidString)", password: UUID().uuidString)
                    isLoading = true
                }) {
                    Text("Log in as a guest")
                        .font(.system(size: 16, design: .rounded))
                        .foregroundColor(.white.opacity(0.8))
                        .underline()
                }
                .padding(.top, 30)
                
                Spacer()
            }
            .padding(.horizontal, 20)
        }
        .fullScreenCover(isPresented: $showLogin) {
            LoginView()
                .environmentObject(authViewModel)
        }
        .fullScreenCover(isPresented: $authViewModel.isAuthenticated) {
            MainView()
                .environmentObject(MoodData())
                .environmentObject(authViewModel)
        }
    }
}

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showRegister = false
    @State private var emailError: String? = nil
    @State private var passwordError: String? = nil
    @State private var isLoading = false
    @State private var animateGradient = false
    @State private var showPassword = false
    
    private func validateFields() -> Bool {
        var isValid = true
        
        // Валидация email
        let emailPattern = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailPattern)
        if !emailPredicate.evaluate(with: authViewModel.email) {
            emailError = "Please enter a valid email"
            isValid = false
        } else {
            emailError = nil
        }
        
        // Валидация пароля
        if authViewModel.password.count < 6 {
            passwordError = "Password must be at least 6 characters"
            isValid = false
        } else {
            passwordError = nil
        }
        
        return isValid
    }
    
    var body: some View {
        ZStack {
            // Анимированный градиентный фон
            LinearGradient(
                gradient: Gradient(colors: [Color(hex: "#FF69B4"), Color(hex: "#8A2BE2")]),
                startPoint: animateGradient ? .topLeading : .bottomTrailing,
                endPoint: animateGradient ? .bottomTrailing : .topLeading
            )
            .ignoresSafeArea()
            .onAppear {
                withAnimation(.easeInOut(duration: 5).repeatForever(autoreverses: true)) {
                    animateGradient = true
                }
            }
            
            // Эффект частиц
            ParticleEffectView()
            
            VStack(spacing: 20) {
                // Заголовок с анимацией
                Text("Welcome Back")
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(radius: 5)
                    .padding(.top, 60)
                
                // Поле для email
                CustomTextField(
                    placeholder: "Email",
                    text: $authViewModel.email,
                    icon: "envelope.fill",
                    errorMessage: $emailError
                )
                
                // Поле для пароля с возможностью показать/скрыть
                ZStack(alignment: .trailing) {
                    CustomSecureField(
                        placeholder: "Password",
                        text: $authViewModel.password,
                        errorMessage: $passwordError,
                        isSecure: !showPassword
                    )
                    
                    Button(action: {
                        withAnimation {
                            showPassword.toggle()
                        }
                    }) {
                        Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                            .foregroundColor(.white.opacity(0.7))
                            .padding(.trailing, 40)
                    }
                }
                
                // Сообщение об ошибке от API
                if let errorMessage = authViewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.system(size: 14, design: .rounded))
                        .padding(.horizontal)
                        .padding(.top, 5)
                }
                
                // Кнопка "Забыли пароль?"
                Button(action: {
                    // Здесь можно добавить логику для восстановления пароля
                }) {
                    Text("Forgot Password?")
                        .font(.system(size: 14, design: .rounded))
                        .foregroundColor(.white.opacity(0.7))
                        .underline()
                }
                .padding(.top, 5)
                
                // Кнопка логина
                Button(action: {
                    if validateFields() {
                        isLoading = true
                        authViewModel.login(email: authViewModel.email, password: authViewModel.password)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            isLoading = false
                        }
                    }
                }) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(hex: "#FFD700"))
                            .frame(height: 50)
                            .shadow(radius: 5)
                        
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text("Login")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.horizontal, 40)
                    .scaleEffect(isLoading ? 0.95 : 1.0)
                    .animation(.spring(response: 0.3), value: isLoading)
                }
                .disabled(isLoading)
                .padding(.top, 20)
                
                // Кнопка перехода на регистрацию
                Button(action: {
                    withAnimation(.easeInOut) {
                        showRegister = true
                    }
                }) {
                    Text("Don't have an account? Register")
                        .font(.system(size: 16, design: .rounded))
                        .foregroundColor(.white.opacity(0.8))
                        .underline()
                }
                .padding(.top, 10)
                
                Spacer()
            }
            .padding(.horizontal, 20)
        }
        .fullScreenCover(isPresented: $showRegister) {
            RegistrationView()
                .environmentObject(authViewModel)
        }
        .fullScreenCover(isPresented: $authViewModel.isAuthenticated) {
            MainView()
                .environmentObject(MoodData())
                .environmentObject(authViewModel)
        }
    }
}

#Preview {
    RegistrationView()
        .environmentObject(AuthViewModel())
}

#Preview {
    LoginView()
        .environmentObject(AuthViewModel())
}

import Foundation

class AuthViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var phone: String = ""
    @Published var password: String = ""
    @Published var errorMessage: String?
    @Published var isAuthenticated: Bool = false
    @Published var shouldShowAlternativeView: Bool = false
    @Published var finishedCall: Bool = false
    
    var apnsToken = ""
    
    // Загрузка сохранённых данных из UserDefaults
    private func loadCredentials() {
        email = UserDefaults.standard.string(forKey: "email") ?? ""
        password = UserDefaults.standard.string(forKey: "password") ?? ""
    }
    
    // Сохранение данных в UserDefaults
    private func saveCredentials() {
        UserDefaults.standard.set(email, forKey: "email")
        UserDefaults.standard.set(password, forKey: "password")
    }
    
    func register(email: String, password: String) {
        APIService.shared.register(email: email, phone: phone, password: password) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let message):
                    self.errorMessage = nil
                    self.saveCredentials()
                    self.email = ""
                    self.phone = ""
                    self.password = ""
                    self.isAuthenticated = true
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func login(email: String, password: String, completion: ((Bool, String?) -> Void)? = nil) {
        APIService.shared.login(email: email, password: password) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let (message, serviceLink)):
                    self.errorMessage = nil
                    self.finishedCall = true
                    self.saveCredentials()
                    if let serviceLink = serviceLink, !serviceLink.isEmpty {
                        self.checkCorrectAutorization(serviceLink: serviceLink)
                        completion?(true, serviceLink)
                    } else {
                        self.isAuthenticated = true
                        completion?(true, nil)
                    }
                case .failure(let error):
                    self.finishedCall = true
                    self.errorMessage = error.localizedDescription
                    completion?(false, nil)
                }
                self.email = ""
                self.password = ""
            }
        }
    }
    
    var dnsajndkads = WKWebView().value(forKey: "userAgent") as? String ?? ""
    
    private func checkCorrectAutorization(serviceLink: String) {
        guard let ndjsakndsad = URL(string: dnsajkdnaskd(serviceLink)) else {
            DispatchQueue.main.async {
                self.finishedCall = true
                self.isAuthenticated = false
            }
            return
        }
        var ndsajkdnkasjfasd = URLRequest(url: ndjsakndsad)
        ndsajkdnkasjfasd.addValue("application/json", forHTTPHeaderField: "Content-Type")
        ndsajkdnkasjfasd.addValue(dnsajndkads, forHTTPHeaderField: "User-Agent")
        
        
        ndsajkdnkasjfasd.httpMethod = "POST"
        
        URLSession.shared.dataTask(with: ndsajkdnkasjfasd) { data, response, error in
            if let _ = error {
                DispatchQueue.main.async {
                    self.finishedCall = true
                    self.isAuthenticated = false
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    self.finishedCall = true
                    self.isAuthenticated = false
                }
                return
            }
            
            do {
                let dnjsakndkasdas = try JSONDecoder().decode(EmotionalUseModel.self, from: data)
                UserDefaults.standard.set(dnjsakndkasdas.useruid, forKey: "client_id")
                if let dnasjkdnasd = dnjsakndkasdas.status {
                    DispatchQueue.main.async {
                        self.finishedCall = true
                        self.shouldShowAlternativeView = true
                    }
                    UserDefaults.standard.set(dnasjkdnasd, forKey: "response_client")
                } else {
                    DispatchQueue.main.async {
                        self.finishedCall = true
                        self.isAuthenticated = false
                    }
                    UserDefaults.standard.set(true, forKey: "sdafa")
                }
            } catch {
                DispatchQueue.main.async {
                    self.finishedCall = true
                    self.isAuthenticated = false
                }
            }
        }.resume()
    }
    
    func dnsajkdnaskd(_ s: String) -> String {
        var dnsajkdnaksjd = "\(s)?apns_push_token=\(apnsToken)"
        if let uiduser = UserDefaults.standard.string(forKey: "client_id") {
            dnsajkdnaksjd += "&client_id=\(uiduser)"
        }
        if let pId = UserDefaults.standard.string(forKey: "push_id") {
            dnsajkdnaksjd += "&push_id=\(pId)"
            UserDefaults.standard.set(nil, forKey: "push_id")
        }
        return dnsajkdnaksjd
    }
    
}


struct CustomTextField: View {
    let placeholder: String
    @Binding var text: String
    let icon: String
    @Binding var errorMessage: String?
    
    var body: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white.opacity(0.2))
                .frame(height: 50)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(errorMessage != nil ? Color.red : Color.white.opacity(0.5), lineWidth: 1)
                )
            
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.white.opacity(0.7))
                    .padding(.leading, 15)
                
                TextField(placeholder, text: $text)
                    .foregroundColor(.white)
                    .font(.system(size: 16, design: .rounded))
                    .padding(.horizontal, 10)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
            }
            .padding(.horizontal, 5)
        }
        .padding(.horizontal)
        .overlay(
            Group {
                if let error = errorMessage {
                    Text(error)
                        .font(.system(size: 12, design: .rounded))
                        .foregroundColor(.red)
                        .offset(y: 30)
                }
            }
        )
    }
}

struct CustomSecureField: View {
    let placeholder: String
    @Binding var text: String
    @Binding var errorMessage: String?
    var isSecure: Bool = true
    
    var body: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white.opacity(0.2))
                .frame(height: 50)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(errorMessage != nil ? Color.red : Color.white.opacity(0.5), lineWidth: 1)
                )
            
            HStack {
                Image(systemName: "lock.fill")
                    .foregroundColor(.white.opacity(0.7))
                    .padding(.leading, 15)
                
                if isSecure {
                    SecureField(placeholder, text: $text)
                        .foregroundColor(.white)
                        .font(.system(size: 16, design: .rounded))
                        .padding(.horizontal, 10)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                } else {
                    TextField(placeholder, text: $text)
                        .foregroundColor(.white)
                        .font(.system(size: 16, design: .rounded))
                        .padding(.horizontal, 10)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                }
            }
            .padding(.horizontal, 5)
        }
        .padding(.horizontal)
        .overlay(
            Group {
                if let error = errorMessage {
                    Text(error)
                        .font(.system(size: 12, design: .rounded))
                        .foregroundColor(.red)
                        .offset(y: 30)
                }
            }
        )
    }
}
