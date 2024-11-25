//
//  SignInView.swift
//  VitalHealth
//
//  Created by TechnoLab on 11/24/24.
//

import SwiftUI
import FirebaseAuth
import AuthenticationServices

struct SignInView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var isAuthenticated = false
    @State private var isShowingSignUp = false
    @State private var errorMessage: String?

    var body: some View {
        if isAuthenticated {
            MainView() // Navigate to the main app after successful sign-in
        } else {
            VStack(spacing: 20) {
                Text("Welcome to VitalHealth")
                    .font(.largeTitle)
                    .padding()

                // Email/Password Authentication
                TextField("Email", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .padding(.horizontal)

                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)

                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                }

                Button(isShowingSignUp ? "Sign Up" : "Sign In") {
                    if isShowingSignUp {
                        signUp(email: email, password: password)
                    } else {
                        signIn(email: email, password: password)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
                .padding(.horizontal)

                Button(isShowingSignUp ? "Already have an account? Sign In" : "Don't have an account? Sign Up") {
                    isShowingSignUp.toggle()
                }
                .foregroundColor(.blue)
                .padding(.top)

                Divider()
                    .padding()

                // Sign in with Apple Button
                SignInWithAppleButton(
                    .signIn,
                    onRequest: { request in
                        request.requestedScopes = [.fullName, .email]
                    },
                    onCompletion: { result in
                        switch result {
                        case .success(let authorization):
                            handleAuthorization(authorization: authorization)
                        case .failure(let error):
                            print("Sign in with Apple failed: \(error.localizedDescription)")
                        }
                    }
                )
                .signInWithAppleButtonStyle(.black)
                .frame(width: 280, height: 45)
            }
            .onAppear {
                checkUserAuthentication()
            }
        }
    }

    // MARK: - Firebase Email/Password Authentication
    private func signUp(email: String, password: String) {
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                errorMessage = error.localizedDescription
                return
            }
            isAuthenticated = true
        }
    }

    private func signIn(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                errorMessage = error.localizedDescription
                return
            }
            isAuthenticated = true
        }
    }

    private func checkUserAuthentication() {
        if let firebaseUser = Auth.auth().currentUser {
            print("Firebase user authenticated: \(firebaseUser.uid)")
            isAuthenticated = true
            return
        }
        
        if let appleUserID = loadFromKeychain() {
            print("Apple Sign-In user ID found in Keychain: \(appleUserID)")
            isAuthenticated = true
            return
        }
        
        print("No authenticated user found")
        isAuthenticated = false
    }

    // MARK: - Sign in with Apple Logic
    private func handleAuthorization(authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            // Extract user details
            let userID = appleIDCredential.user
            let email = appleIDCredential.email
            let fullName = appleIDCredential.fullName

            // Save user ID in Keychain for persistence
            saveToKeychain(userIdentifier: userID)

            // Debugging Information
            print("Apple User ID: \(userID)")
            print("Apple Email: \(email ?? "No Email")")
            print("Apple Full Name: \(fullName?.givenName ?? "No Name")")

            // Authenticate User Locally (or link to Firebase if required)
            isAuthenticated = true
        }
    }

    // MARK: - Keychain Helper Functions
    private func saveToKeychain(userIdentifier: String) {
        let keychainItem = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: "appleUserIdentifier",
            kSecValueData: userIdentifier.data(using: .utf8)!
        ] as CFDictionary

        SecItemDelete(keychainItem) // Delete any existing item
        SecItemAdd(keychainItem, nil) // Add new item
    }

    private func loadFromKeychain() -> String? {
        let query = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: "appleUserIdentifier",
            kSecReturnData: true,
            kSecMatchLimit: kSecMatchLimitOne
        ] as CFDictionary

        var dataTypeRef: AnyObject?
        if SecItemCopyMatching(query, &dataTypeRef) == noErr,
           let data = dataTypeRef as? Data,
           let identifier = String(data: data, encoding: .utf8) {
            return identifier
        }
        return nil
    }
}
