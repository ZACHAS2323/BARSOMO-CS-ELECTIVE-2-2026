const API_BASE = '';
const AUTH_BASE = 'http://localhost:4000';
const AUTH_STORAGE_KEY = 'zachsBlog.auth';

const feed = document.querySelector('#feed');
const postCount = document.querySelector('#post-count');
const loginOpen = document.querySelector('#login-open');
const logoutButton = document.querySelector('#logout-button');
const writeOpen = document.querySelector('#write-open');
const composer = document.querySelector('#composer');
const postForm = document.querySelector('#post-form');
const authDialog = document.querySelector('#auth-dialog');
const loginForm = document.querySelector('#login-form');
const registerForm = document.querySelector('#register-form');
const authTitle = document.querySelector('#auth-title');
const authEyebrow = document.querySelector('#auth-eyebrow');
const authSwitchCopy = document.querySelector('#auth-switch-copy');
const authModeToggle = document.querySelector('#auth-mode-toggle');
let toastTimer;
let editingPostId = null;

function getAuth() {
  try {
    return JSON.parse(localStorage.getItem(AUTH_STORAGE_KEY) || 'null');
  } catch {
    return null;
  }
}

function saveAuth(auth) {
  localStorage.setItem(AUTH_STORAGE_KEY, JSON.stringify(auth));
  updateAuthControls();
}

function clearAuth() {
  localStorage.removeItem(AUTH_STORAGE_KEY);
  updateAuthControls();
}

function decodeToken(token) {
  const encodedPayload = token.split('.')[1];
  if (!encodedPayload) throw new Error('Invalid access token.');
  const base64 = encodedPayload.replace(/-/g, '+').replace(/_/g, '/');
  const binary = atob(base64);
  const bytes = Uint8Array.from(binary, (character) => character.charCodeAt(0));
  return JSON.parse(new TextDecoder().decode(bytes));
}

function updateAuthControls() {
  const auth = getAuth();
  const canWrite = auth && ['author', 'admin'].includes(auth.user?.role);
  loginOpen.hidden = Boolean(auth);
  logoutButton.hidden = !auth;
  writeOpen.hidden = !canWrite;
  if (auth) {
    logoutButton.textContent = `Sign out (${auth.user.username})`;
  }
}

async function refreshAccessToken(auth) {
  const response = await fetch(`${AUTH_BASE}/refresh`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ refreshToken: auth.refreshToken })
  });
  const data = await response.json().catch(() => ({}));
  if (!response.ok || !data.accessToken) return false;
  auth.accessToken = data.accessToken;
  auth.user = decodeToken(data.accessToken);
  saveAuth(auth);
  return true;
}

async function apiRequest(url, options = {}) {
  const auth = getAuth();
  const requestOptions = { ...options, headers: { ...(options.headers || {}) } };
  if (auth?.accessToken) requestOptions.headers.Authorization = `Bearer ${auth.accessToken}`;

  let response = await fetch(`${API_BASE}${url}`, requestOptions);
  if (response.status === 401 && auth?.refreshToken && !options.skipRefresh) {
    try {
      if (await refreshAccessToken(auth)) {
        requestOptions.headers.Authorization = `Bearer ${getAuth().accessToken}`;
        response = await fetch(`${API_BASE}${url}`, requestOptions);
      } else {
        clearAuth();
      }
    } catch {
      clearAuth();
    }
  }

  const data = await response.json().catch(() => ({}));
  if (!response.ok) throw new Error(data.error || 'The request could not be completed.');
  return data;
}

async function authRequest(endpoint, body) {
  const response = await fetch(`${AUTH_BASE}${endpoint}`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(body)
  });
  const data = await response.json().catch(() => ({}));
  if (!response.ok) throw new Error(data.error || 'The account request could not be completed.');
  return data;
}

function element(tagName, className, text) {
  const node = document.createElement(tagName);
  if (className) node.className = className;
  if (text !== undefined) node.textContent = text;
  return node;
}

function formatDate(value) {
  const date = new Date(value);
  if (Number.isNaN(date.getTime())) return 'Recently';
  return new Intl.DateTimeFormat(undefined, { year: 'numeric', month: 'short', day: 'numeric' }).format(date);
}

function readingTime(content) {
  return `${Math.max(1, Math.ceil(String(content || '').trim().split(/\s+/).filter(Boolean).length / 200))} min read`;
}

function makePost(post, index) {
  const article = element('article', 'post');
  article.append(element('span', 'post-index', String(index + 1).padStart(2, '0')));

  const body = element('div', 'post-body');
  const meta = element('div', 'post-meta');
  meta.append(element('span', 'post-category', 'STORY'));
  meta.append(element('time', '', formatDate(post.created_at)));
  body.append(meta);

  const title = element('button', 'post-title', post.title || 'Untitled story');
  title.type = 'button';
  title.setAttribute('aria-expanded', 'false');
  body.append(title);

  const content = String(post.content || '');
  const excerptText = content.length > 260 ? `${content.slice(0, 257).trimEnd()}...` : content;
  const excerpt = element('p', 'post-excerpt', excerptText);
  const fullContent = element('div', 'post-full', content);
  fullContent.hidden = true;
  body.append(excerpt, fullContent);

  const readButton = element('button', 'read-link', 'Read story →');
  readButton.type = 'button';
  readButton.addEventListener('click', () => {
    const expanded = fullContent.hidden;
    fullContent.hidden = !expanded;
    excerpt.hidden = expanded;
    title.setAttribute('aria-expanded', String(expanded));
    readButton.textContent = expanded ? 'Close story ↑' : 'Read story →';
  });
  title.addEventListener('click', () => readButton.click());
  body.append(readButton);

  const side = element('div', 'post-side');
  side.append(element('span', 'post-author', readingTime(content)));

  const auth = getAuth();
  const isAdmin = auth?.user?.role === 'admin';
  const isOwner = String(post.user_id) === String(auth?.user?.id);
  if (isAdmin || isOwner) {
    const actions = element('div', 'post-actions');
    const editButton = element('button', 'post-action', 'Edit');
    editButton.type = 'button';
    editButton.addEventListener('click', () => {
      editingPostId = String(post.id);
      document.querySelector('#composer-title').textContent = 'Edit story';
      postForm.querySelector('[type="submit"]').innerHTML = 'Save changes <span aria-hidden="true">↗</span>';
      postForm.elements.title.value = post.title;
      postForm.elements.content.value = post.content;
      composer.hidden = false;
      composer.scrollIntoView({ behavior: 'smooth', block: 'start' });
      document.querySelector('#post-title').focus({ preventScroll: true });
    });
    actions.append(editButton);

    if (isAdmin) {
      const deleteButton = element('button', 'post-action post-action-danger', 'Delete');
      deleteButton.type = 'button';
      deleteButton.addEventListener('click', async () => {
        if (!window.confirm(`Delete "${post.title}"? This cannot be undone.`)) return;
        try {
          await apiRequest(`/api/posts/${encodeURIComponent(post.id)}`, { method: 'DELETE' });
          showToast('The story was deleted.');
          await loadPosts();
        } catch (error) {
          showToast(error.message);
        }
      });
      actions.append(deleteButton);
    }
    side.append(actions);
  }

  article.append(body, side);
  return article;
}

async function loadPosts() {
  feed.replaceChildren(element('div', 'loading-row', 'Finding the latest stories...'));
  postCount.textContent = 'Loading stories...';
  try {
    const posts = await apiRequest('/api/posts');
    if (!Array.isArray(posts)) throw new Error('The server returned an unexpected response.');
    posts.sort((first, second) => new Date(second.created_at || 0) - new Date(first.created_at || 0));
    postCount.textContent = `${posts.length} ${posts.length === 1 ? 'story' : 'stories'}`;
    feed.replaceChildren();
    if (posts.length === 0) {
      const empty = element('div', 'empty-state');
      empty.append(element('strong', '', 'The page is yours to fill.'));
      empty.append(element('span', '', 'No stories yet. Check back soon for the first one.'));
      feed.append(empty);
      return;
    }
    posts.forEach((post, index) => feed.append(makePost(post, index)));
  } catch (error) {
    postCount.textContent = 'Unable to load';
    feed.replaceChildren(element('p', 'loading-row error-state', `${error.message} Make sure both servers are running, then reload the page.`));
  }
}

function showToast(message) {
  const toast = document.querySelector('#toast');
  toast.textContent = message;
  toast.classList.add('visible');
  clearTimeout(toastTimer);
  toastTimer = setTimeout(() => toast.classList.remove('visible'), 3000);
}

function setFormMessage(id, message) {
  document.querySelector(id).textContent = message;
}

function setAuthMode(registerMode) {
  loginForm.hidden = registerMode;
  registerForm.hidden = !registerMode;
  authTitle.textContent = registerMode ? 'Create an account' : 'Sign in';
  authEyebrow.textContent = registerMode ? 'Join the conversation' : 'Good to have you back';
  authSwitchCopy.textContent = registerMode ? 'Already have an account?' : 'New here?';
  authModeToggle.textContent = registerMode ? 'Sign in' : 'Create an account';
  setFormMessage('#login-message', '');
  setFormMessage('#register-message', '');
}

function openAuthDialog(registerMode = false) {
  setAuthMode(registerMode);
  authDialog.showModal();
}

loginOpen.addEventListener('click', () => openAuthDialog(false));
document.querySelector('#auth-close').addEventListener('click', () => authDialog.close());
authModeToggle.addEventListener('click', () => setAuthMode(registerForm.hidden));

authDialog.addEventListener('click', (event) => {
  if (event.target === authDialog) authDialog.close();
});

loginForm.addEventListener('submit', async (event) => {
  event.preventDefault();
  setFormMessage('#login-message', '');
  const formData = new FormData(loginForm);
  try {
    const data = await authRequest('/login', {
      username: formData.get('username'),
      password: formData.get('password')
    });
    saveAuth({
      accessToken: data.accessToken,
      refreshToken: data.refreshToken,
      user: decodeToken(data.accessToken)
    });
    authDialog.close();
    showToast(`Welcome back, ${getAuth().user.username}.`);
    await loadPosts();
  } catch (error) {
    setFormMessage('#login-message', error.message);
  }
});

registerForm.addEventListener('submit', async (event) => {
  event.preventDefault();
  setFormMessage('#register-message', '');
  const formData = new FormData(registerForm);
  try {
    await authRequest('/register', {
      username: formData.get('username'),
      password: formData.get('password'),
      role: formData.get('role')
    });
    loginForm.elements.username.value = formData.get('username');
    setAuthMode(false);
    setFormMessage('#login-message', 'Account created. Sign in to continue.');
  } catch (error) {
    setFormMessage('#register-message', error.message);
  }
});

logoutButton.addEventListener('click', async () => {
  const auth = getAuth();
  try {
    if (auth?.refreshToken) await authRequest('/logout', { refreshToken: auth.refreshToken });
  } catch {
    // Clear the local session even if the Auth Server cannot be reached.
  }
  clearAuth();
  showToast('You have signed out.');
  await loadPosts();
});

writeOpen.addEventListener('click', () => {
  editingPostId = null;
  postForm.reset();
  document.querySelector('#composer-title').textContent = 'A new story';
  postForm.querySelector('[type="submit"]').innerHTML = 'Publish story <span aria-hidden="true">↗</span>';
  setFormMessage('#post-message', '');
  composer.hidden = false;
  composer.scrollIntoView({ behavior: 'smooth', block: 'start' });
  document.querySelector('#post-title').focus({ preventScroll: true });
});

document.querySelector('#write-close').addEventListener('click', () => {
  editingPostId = null;
  postForm.reset();
  document.querySelector('#composer-title').textContent = 'A new story';
  postForm.querySelector('[type="submit"]').innerHTML = 'Publish story <span aria-hidden="true">↗</span>';
  composer.hidden = true;
  setFormMessage('#post-message', '');
});

postForm.addEventListener('submit', async (event) => {
  event.preventDefault();
  setFormMessage('#post-message', '');
  const formData = new FormData(postForm);
  const updatingPost = Boolean(editingPostId);
  try {
    await apiRequest(updatingPost ? `/api/posts/${encodeURIComponent(editingPostId)}` : '/api/posts', {
      method: updatingPost ? 'PUT' : 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ title: formData.get('title'), content: formData.get('content') })
    });
    editingPostId = null;
    postForm.reset();
    composer.hidden = true;
    document.querySelector('#composer-title').textContent = 'A new story';
    postForm.querySelector('[type="submit"]').innerHTML = 'Publish story <span aria-hidden="true">↗</span>';
    showToast(updatingPost ? 'Your changes are saved.' : 'Your story is published.');
    await loadPosts();
  } catch (error) {
    setFormMessage('#post-message', error.message);
    if (!getAuth()) openAuthDialog(false);
  }
});

document.querySelector('#today-label').textContent = new Intl.DateTimeFormat(undefined, {
  weekday: 'long', month: 'long', day: 'numeric', year: 'numeric'
}).format(new Date()).toUpperCase();

updateAuthControls();
loadPosts();
