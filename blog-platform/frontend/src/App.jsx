import { useCallback, useEffect, useState } from 'react';

const AUTH_URL = 'http://localhost:4000';
const API_URL = 'http://localhost:5000/api';
const readStoredUser = () => {
  try {
    return JSON.parse(localStorage.getItem('blogUser') || 'null');
  } catch {
    return null;
  }
};

async function request(url, options = {}) {
  const response = await fetch(url, {
    ...options,
    headers: { 'Content-Type': 'application/json', ...(options.headers || {}) }
  });
  const data = await response.json().catch(() => ({}));
  if (!response.ok) throw new Error(data.error || 'The request could not be completed.');
  return data;
}

export default function App() {
  const [user, setUser] = useState(readStoredUser);
  const [accessToken, setAccessToken] = useState(localStorage.getItem('blogAccessToken') || '');
  const [refreshToken, setRefreshToken] = useState(localStorage.getItem('blogRefreshToken') || '');
  const [posts, setPosts] = useState([]);
  const [selectedPost, setSelectedPost] = useState(null);
  const [authMode, setAuthMode] = useState('login');
  const [form, setForm] = useState({ username: '', email: '', password: '', role: 'reader' });
  const [postForm, setPostForm] = useState({ title: '', content: '' });
  const [editingId, setEditingId] = useState(null);
  const [busy, setBusy] = useState(false);
  const [notice, setNotice] = useState('');
  const [error, setError] = useState('');

  const loadPosts = useCallback(async () => {
    try {
      setPosts(await request(`${API_URL}/posts`));
    } catch (err) {
      setError(err.message);
    }
  }, []);

  useEffect(() => {
    loadPosts();
  }, [loadPosts]);

  const withToken = useCallback(async (url, options = {}) => {
    let token = accessToken;
    const send = (currentToken) => request(url, {
      ...options,
      headers: { ...(options.headers || {}), Authorization: `Bearer ${currentToken}` }
    });
    try {
      return await send(token);
    } catch (err) {
      if (!refreshToken || !err.message.toLowerCase().includes('token')) throw err;
      const refreshed = await request(`${AUTH_URL}/refresh`, {
        method: 'POST',
        body: JSON.stringify({ refreshToken })
      });
      token = refreshed.accessToken;
      setAccessToken(token);
      localStorage.setItem('blogAccessToken', token);
      return send(token);
    }
  }, [accessToken, refreshToken]);

  async function submitAuth(event) {
    event.preventDefault();
    setBusy(true);
    setError('');
    setNotice('');
    try {
      const endpoint = authMode === 'login' ? 'login' : 'register';
      const payload = authMode === 'login'
        ? { username: form.username, password: form.password }
        : { username: form.username, email: form.email, password: form.password, role: form.role };
      const result = await request(`${AUTH_URL}/${endpoint}`, {
        method: 'POST',
        body: JSON.stringify(payload)
      });
      if (authMode === 'register') {
        setNotice('Account created. Sign in to continue.');
        setAuthMode('login');
      } else {
        setUser(result.user);
        setAccessToken(result.accessToken);
        setRefreshToken(result.refreshToken);
        localStorage.setItem('blogUser', JSON.stringify(result.user));
        localStorage.setItem('blogAccessToken', result.accessToken);
        localStorage.setItem('blogRefreshToken', result.refreshToken);
      }
    } catch (err) {
      setError(err.message);
    } finally {
      setBusy(false);
    }
  }

  async function logout() {
    try {
      if (refreshToken) {
        await request(`${AUTH_URL}/logout`, {
          method: 'POST',
          body: JSON.stringify({ refreshToken })
        });
      }
    } catch (err) {
      setError(err.message);
      return;
    }
    setUser(null);
    setAccessToken('');
    setRefreshToken('');
    localStorage.removeItem('blogUser');
    localStorage.removeItem('blogAccessToken');
    localStorage.removeItem('blogRefreshToken');
  }

  function startCreate() {
    setEditingId(null);
    setPostForm({ title: '', content: '' });
    setSelectedPost(null);
    setError('');
  }

  function startEdit(post) {
    setEditingId(post.id);
    setPostForm({ title: post.title, content: post.content });
    setSelectedPost(null);
    setError('');
  }

  async function savePost(event) {
    event.preventDefault();
    setBusy(true);
    setError('');
    try {
      await withToken(
        editingId ? `${API_URL}/posts/${editingId}` : `${API_URL}/posts`,
        {
          method: editingId ? 'PUT' : 'POST',
          body: JSON.stringify(postForm)
        }
      );
      setEditingId(null);
      setPostForm({ title: '', content: '' });
      setNotice(editingId ? 'Post updated.' : 'Post published.');
      await loadPosts();
    } catch (err) {
      setError(err.message);
    } finally {
      setBusy(false);
    }
  }

  async function deletePost(post) {
    if (!window.confirm(`Delete "${post.title}"? This cannot be undone.`)) return;
    setError('');
    try {
      await withToken(`${API_URL}/posts/${post.id}`, { method: 'DELETE' });
      setSelectedPost(null);
      setNotice('Post deleted.');
      await loadPosts();
    } catch (err) {
      setError(err.message);
    }
  }

  const canWrite = user && ['author', 'admin'].includes(user.role);

  return (
    <div className="site-shell">
      <header className="topbar">
        <a className="wordmark" href="#" onClick={() => { setSelectedPost(null); setEditingId(null); }}>
          <span className="mark">f.</span>
          <span>fieldnotes<span className="wordmark-period">.</span></span>
        </a>
        <nav className="top-actions" aria-label="Account">
          {user ? (
            <>
              <span className="user-chip"><i>{user.username.slice(0, 1).toUpperCase()}</i>{user.username}<b>{user.role}</b></span>
              <button className="text-button" onClick={logout}>Sign out</button>
            </>
          ) : <a className="nav-link" href="#account">Sign in</a>}
        </nav>
      </header>

      <main>
        <section className="hero">
          <div className="hero-copy">
            <p className="eyebrow"><span className="eyebrow-line" /> A PLACE FOR IDEAS</p>
            <h1>Stories worth<br /><em>staying for.</em></h1>
            <p className="hero-intro">A little corner of the internet for thoughtful writing, curious minds, and the things we can't stop thinking about.</p>
            <a className="discover-link" href="#stories">Discover stories <span>↓</span></a>
          </div>
          <div className="hero-art" aria-hidden="true">
            <div className="sun" />
            <div className="art-label">VOL. 01<br />EST. 2026</div>
            <div className="arch arch-back" />
            <div className="arch arch-front" />
            <div className="art-ground" />
            <div className="art-caption">WORDS THAT<br />MAKE US HUMAN.</div>
          </div>
        </section>

        <div className="content-grid">
          <section className="stories-section" id="stories">
            <div className="section-heading">
              <div><p className="eyebrow">THE JOURNAL</p><h2>{selectedPost ? 'A closer look' : 'Latest stories'}</h2></div>
              <span className="story-count">{String(posts.length).padStart(2, '0')} STORIES</span>
            </div>

            {notice && <div className="notice" role="status">{notice}<button onClick={() => setNotice('')} aria-label="Dismiss">×</button></div>}
            {error && <div className="error-box" role="alert">{error}<button onClick={() => setError('')} aria-label="Dismiss">×</button></div>}

            {selectedPost ? (
              <article className="full-post">
                <button className="back-link" onClick={() => setSelectedPost(null)}>← Back to stories</button>
                <p className="post-meta">{selectedPost.author_username} <span>·</span> {new Date(selectedPost.created_at).toLocaleDateString()}</p>
                <h3>{selectedPost.title}</h3>
                <div className="full-content">{selectedPost.content}</div>
                {(user?.role === 'admin' || user?.id === selectedPost.author_id) && (
                  <div className="post-controls">
                    <button className="outline-button" onClick={() => startEdit(selectedPost)}>Edit story</button>
                    {user.role === 'admin' && <button className="danger-button" onClick={() => deletePost(selectedPost)}>Delete</button>}
                  </div>
                )}
              </article>
            ) : (
              <div className="story-list">
                {posts.length === 0 ? <p className="empty-state">No stories yet. Be the first to write one.</p> : posts.map((post, index) => (
                  <article className="story-card" key={post.id}>
                    <button className="story-open" onClick={() => setSelectedPost(post)}>
                      <span className="story-number">{String(index + 1).padStart(2, '0')}</span>
                      <span className="story-body">
                        <span className="post-meta">{post.author_username} <span>·</span> {new Date(post.created_at).toLocaleDateString()}</span>
                        <strong>{post.title}</strong>
                        <span className="story-excerpt">{post.content.slice(0, 180)}{post.content.length > 180 ? '…' : ''}</span>
                        <span className="read-more">Read story <span>↗</span></span>
                      </span>
                    </button>
                    {(user?.role === 'admin' || user?.id === post.author_id) && (
                      <button className="edit-icon" onClick={() => startEdit(post)} aria-label={`Edit ${post.title}`}>✎</button>
                    )}
                  </article>
                ))}
              </div>
            )}

            {canWrite && !selectedPost && (
              <section className="editor-card">
                <p className="eyebrow">{editingId ? 'MAKE IT BETTER' : 'YOUR TURN'}</p>
                <h3>{editingId ? 'Edit your story' : 'Have a story to tell?'}</h3>
                <form onSubmit={savePost}>
                  <label>Title<input maxLength="255" required value={postForm.title} onChange={(event) => setPostForm({ ...postForm, title: event.target.value })} /></label>
                  <label>Your story<textarea rows="6" required value={postForm.content} onChange={(event) => setPostForm({ ...postForm, content: event.target.value })} /></label>
                  <div className="form-actions">
                    <button className="primary-button" disabled={busy}>{busy ? 'Saving…' : editingId ? 'Save changes' : 'Publish story'} <span>↗</span></button>
                    {editingId && <button type="button" className="text-button" onClick={startCreate}>Cancel edit</button>}
                  </div>
                </form>
              </section>
            )}
          </section>

          <aside className="sidebar">
            {user ? (
              <div className="account-card">
                <div className="sidebar-icon">✳</div>
                <p className="eyebrow">YOUR SPACE</p>
                <h3>Welcome,<br /><em>{user.username}.</em></h3>
                <p>You're here as a <strong>{user.role}</strong>. {canWrite ? 'Your next story is only a few words away.' : 'Enjoy exploring the journal.'}</p>
                {canWrite && !selectedPost && <button className="primary-button wide" onClick={startCreate}>Write a story <span>↗</span></button>}
              </div>
            ) : (
              <div className="account-card" id="account">
                <div className="sidebar-icon">✳</div>
                <p className="eyebrow">{authMode === 'login' ? 'WELCOME BACK' : 'JOIN THE JOURNAL'}</p>
                <h3>{authMode === 'login' ? <>Good to<br /><em>see you.</em></> : <>Make yourself<br /><em>at home.</em></>}</h3>
                <form className="auth-form" onSubmit={submitAuth}>
                  <label>Username<input autoComplete="username" required value={form.username} onChange={(event) => setForm({ ...form, username: event.target.value })} /></label>
                  {authMode === 'register' && <>
                    <label>Email <span className="optional">(optional)</span><input type="email" autoComplete="email" value={form.email} onChange={(event) => setForm({ ...form, email: event.target.value })} /></label>
                    <label>I'm joining as<select value={form.role} onChange={(event) => setForm({ ...form, role: event.target.value })}><option value="reader">Reader</option><option value="author">Author</option></select></label>
                  </>}
                  <label>Password<input type="password" autoComplete={authMode === 'login' ? 'current-password' : 'new-password'} minLength="8" required value={form.password} onChange={(event) => setForm({ ...form, password: event.target.value })} /></label>
                  <button className="primary-button wide" disabled={busy}>{busy ? 'Please wait…' : authMode === 'login' ? 'Sign in' : 'Create account'} <span>↗</span></button>
                </form>
                <p className="switch-auth">{authMode === 'login' ? 'New around here?' : 'Already have an account?'} <button onClick={() => { setAuthMode(authMode === 'login' ? 'register' : 'login'); setError(''); }}>{authMode === 'login' ? 'Join us' : 'Sign in'}</button></p>
              </div>
            )}

            <div className="about-card">
              <p className="eyebrow">A NOTE ON THIS SPACE</p>
              <p>We believe the best stories don't shout. They stay with you, quietly, long after the page is turned.</p>
              <span className="signature">— The Fieldnotes team</span>
            </div>
            <div className="sidebar-footer">A SMALL SPACE FOR BIG THOUGHTS <span>✳</span></div>
          </aside>
        </div>
      </main>
      <footer className="footer"><a className="wordmark" href="#"><span className="mark">f.</span><span>fieldnotes<span className="wordmark-period">.</span></span></a><span>MADE FOR THE LOVE OF WORDS · 2026</span></footer>
    </div>
  );
}
