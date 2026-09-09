const STORAGE_KEY = 'quest-log-tasks';

const state = {
  tasks: loadTasks(),
  filter: 'all',
  isDeletingAll: false,
};

const elements = {
  form: document.querySelector('#taskForm'),
  input: document.querySelector('#taskInput'),
  formMessage: document.querySelector('#formMessage'),
  taskList: document.querySelector('#taskList'),
  emptyState: document.querySelector('#emptyState'),
  deleteAllButton: document.querySelector('#deleteAllButton'),
  statusMessage: document.querySelector('#statusMessage'),
  scoreValue: document.querySelector('#scoreValue'),
  allCount: document.querySelector('#allCount'),
  activeCount: document.querySelector('#activeCount'),
  completedCount: document.querySelector('#completedCount'),
};

function loadTasks() {
  try {
    const savedTasks = JSON.parse(localStorage.getItem(STORAGE_KEY));
    return Array.isArray(savedTasks) ? savedTasks : [];
  } catch {
    return [];
  }
}

function saveTasks() {
  localStorage.setItem(STORAGE_KEY, JSON.stringify(state.tasks));
}

function createTask(title) {
  return {
    id: crypto.randomUUID ? crypto.randomUUID() : `${Date.now()}-${Math.random()}`,
    title,
    completed: false,
    createdAt: new Date().toISOString(),
  };
}

function addTask(event) {
  event.preventDefault();
  const title = elements.input.value.trim();

  if (!title) {
    elements.formMessage.textContent = 'MISSION ERROR: ENTER A TASK FIRST.';
    elements.input.focus();
    return;
  }

  state.tasks.unshift(createTask(title));
  saveTasks();
  elements.input.value = '';
  elements.formMessage.textContent = '';
  elements.statusMessage.textContent = 'MISSION ADDED';
  render();
  elements.input.focus();
}

function toggleTask(taskId) {
  state.tasks = state.tasks.map((task) => task.id === taskId
    ? { ...task, completed: !task.completed }
    : task);
  saveTasks();
  elements.statusMessage.textContent = 'STATUS UPDATED';
  render();
}

function deleteTask(taskId) {
  state.tasks = state.tasks.filter((task) => task.id !== taskId);
  saveTasks();
  elements.statusMessage.textContent = 'MISSION DELETED';
  render();
}

function deleteAllTasks() {
  if (!state.tasks.length || state.isDeletingAll) return;

  state.isDeletingAll = true;
  elements.deleteAllButton.disabled = true;
  elements.deleteAllButton.textContent = 'CLEARING...';
  elements.statusMessage.textContent = 'SAVING CLEARANCE...';

  setTimeout(() => {
    state.tasks = [];
    saveTasks();
    state.isDeletingAll = false;
    elements.deleteAllButton.disabled = false;
    elements.deleteAllButton.textContent = 'DELETE ALL';
    elements.statusMessage.textContent = 'BOARD CLEARED';
    render();
  }, 2000);
}

function getVisibleTasks() {
  if (state.filter === 'active') return state.tasks.filter((task) => !task.completed);
  if (state.filter === 'completed') return state.tasks.filter((task) => task.completed);
  return state.tasks;
}

function render() {
  const visibleTasks = getVisibleTasks();
  elements.taskList.innerHTML = '';
  elements.emptyState.hidden = visibleTasks.length > 0;
  elements.deleteAllButton.disabled = state.tasks.length === 0 || state.isDeletingAll;

  visibleTasks.forEach((task) => {
    const item = document.createElement('li');
    item.className = `task-item${task.completed ? ' completed' : ''}`;

    const checkbox = document.createElement('input');
    checkbox.type = 'checkbox';
    checkbox.className = 'task-check';
    checkbox.checked = task.completed;
    checkbox.setAttribute('aria-label', `Mark ${task.title} as complete`);
    checkbox.addEventListener('change', () => toggleTask(task.id));

    const copy = document.createElement('div');
    copy.className = 'task-copy';
    const title = document.createElement('div');
    title.className = 'task-name';
    title.textContent = task.title;
    const meta = document.createElement('div');
    meta.className = 'task-meta';
    meta.textContent = task.completed ? 'MISSION CLEAR' : 'IN PROGRESS';
    copy.append(title, meta);

    const deleteButton = document.createElement('button');
    deleteButton.className = 'delete-button';
    deleteButton.type = 'button';
    deleteButton.title = `Delete ${task.title}`;
    deleteButton.setAttribute('aria-label', `Delete ${task.title}`);
    deleteButton.textContent = '×';
    deleteButton.addEventListener('click', () => deleteTask(task.id));

    item.append(checkbox, copy, deleteButton);
    elements.taskList.append(item);
  });

  const completedCount = state.tasks.filter((task) => task.completed).length;
  elements.allCount.textContent = state.tasks.length;
  elements.activeCount.textContent = state.tasks.length - completedCount;
  elements.completedCount.textContent = completedCount;
  elements.scoreValue.textContent = String(completedCount * 100).padStart(6, '0');
}

function setFilter(event) {
  const button = event.target.closest('[data-filter]');
  if (!button) return;
  state.filter = button.dataset.filter;
  document.querySelectorAll('[data-filter]').forEach((filterButton) => {
    filterButton.classList.toggle('active', filterButton === button);
  });
  render();
}

elements.form.addEventListener('submit', addTask);
elements.deleteAllButton.addEventListener('click', deleteAllTasks);
document.querySelector('.filter-row').addEventListener('click', setFilter);
render();
