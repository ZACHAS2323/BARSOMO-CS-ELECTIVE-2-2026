document.addEventListener("DOMContentLoaded", () => {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    const passwordRegex = /^(?=.*\d).{8,}$/;

    function showError(inputId, errorId, message) {
        const input = document.getElementById(inputId);
        const error = document.getElementById(errorId);
        input.classList.add('error');
        error.innerText = message;
    }

    function clearError(inputId, errorId) {
        const input = document.getElementById(inputId);
        const error = document.getElementById(errorId);
        input.classList.remove('error');
        error.innerText = '';
    }

    const signupForm = document.getElementById('signupForm');
    if (signupForm) {
        const emailInput = document.getElementById('signupEmail');
        const phoneInput = document.getElementById('signupPhone');
        const passwordInput = document.getElementById('signupPassword');

        const validateSignupEmail = () => {
            if (!emailInput.value.trim() || !emailRegex.test(emailInput.value)) {
                showError('signupEmail', 'signupEmailError', 'Please enter a valid email address.');
                return false;
            }
            clearError('signupEmail', 'signupEmailError');
            return true;
        };

        const validateSignupPhone = () => {
            if (!phoneInput.value.trim()) {
                showError('signupPhone', 'signupPhoneError', 'Phone number is required.');
                return false;
            }
            clearError('signupPhone', 'signupPhoneError');
            return true;
        };

        const validateSignupPassword = () => {
            if (!passwordRegex.test(passwordInput.value)) {
                showError('signupPassword', 'signupPasswordError', 'Password must be at least 8 characters and contain a number.');
                return false;
            }
            clearError('signupPassword', 'signupPasswordError');
            return true;
        };

        emailInput.addEventListener('blur', validateSignupEmail);
        emailInput.addEventListener('input', validateSignupEmail);
        phoneInput.addEventListener('blur', validateSignupPhone);
        phoneInput.addEventListener('input', validateSignupPhone);
        passwordInput.addEventListener('blur', validateSignupPassword);
        passwordInput.addEventListener('input', validateSignupPassword);

        signupForm.addEventListener('submit', (e) => {
            e.preventDefault();
            const isEmailValid = validateSignupEmail();
            const isPhoneValid = validateSignupPhone();
            const isPasswordValid = validateSignupPassword();

            if (isEmailValid && isPhoneValid && isPasswordValid) {
                window.location.href = 'welcome.html';
            }
        });
    }

    const signinForm = document.getElementById('signinForm');
    if (signinForm) {
        const emailInput = document.getElementById('signinEmail');
        const passwordInput = document.getElementById('signinPassword');

        const validateSigninEmail = () => {
            if (!emailInput.value.trim()) {
                showError('signinEmail', 'signinEmailError', 'Email cannot be empty.');
                return false;
            } else if (!emailRegex.test(emailInput.value)) {
                showError('signinEmail', 'signinEmailError', 'Please enter a valid email address.');
                return false;
            }
            clearError('signinEmail', 'signinEmailError');
            return true;
        };

        const validateSigninPassword = () => {
            if (!passwordInput.value.trim()) {
                showError('signinPassword', 'signinPasswordError', 'Password cannot be empty.');
                return false;
            }
            clearError('signinPassword', 'signinPasswordError');
            return true;
        };

        emailInput.addEventListener('blur', validateSigninEmail);
        emailInput.addEventListener('input', validateSigninEmail);
        passwordInput.addEventListener('blur', validateSigninPassword);
        passwordInput.addEventListener('input', validateSigninPassword);

        signinForm.addEventListener('submit', (e) => {
            e.preventDefault();
            const isEmailValid = validateSigninEmail();
            const isPasswordValid = validateSigninPassword();

            if (isEmailValid && isPasswordValid) {
                window.location.href = 'welcome.html';
            }
        });
    }
});
