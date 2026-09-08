import http from 'k6/http';
import { check, sleep } from 'k6';

const BASE_URL = 'http://localhost:5259';

export const options = {
  scenarios: {
    // 1. Tasks & Projects (70% -> 350 VUs)
    tasks_projects: {
      executor: 'ramping-vus',
      exec: 'tasksAndProjectsFlow',
      stages: [
        { duration: '20s', target: 150 },
        { duration: '45s', target: 350 },
        { duration: '15s', target: 0 },
      ],
    },

    // 2. Workspaces (15% -> 75 VUs)
    workspaces: {
      executor: 'ramping-vus',
      exec: 'workspacesFlow',
      stages: [
        { duration: '20s', target: 35 },
        { duration: '45s', target: 75 },
        { duration: '15s', target: 0 },
      ],
    },

    // 3. Auth (15% -> 75 VUs)
    auth: {
      executor: 'ramping-vus',
      exec: 'authFlow',
      stages: [
        { duration: '20s', target: 35 },
        { duration: '45s', target: 75 },
        { duration: '15s', target: 0 },
      ],
    },
  },

  thresholds: {
    'http_req_failed': ['rate<0.01'],
    'http_req_duration{scenario:tasks_projects}': ['p(95)<500'],
    'http_req_duration{scenario:workspaces}': ['p(95)<150'],
    'http_req_duration{scenario:auth}': ['p(95)<150'],
  },
};

export function setup() {
  const user = {
    name: 'Stress Lead',
    email: `distributed_${Date.now()}@projecthub.local`,
    password: 'Password123!',
  };

  http.post(`${BASE_URL}/auth/register`, JSON.stringify(user), {
    headers: { 'Content-Type': 'application/json' },
  });

  const loginRes = http.post(
    `${BASE_URL}/auth/login`,
    JSON.stringify({ email: user.email, password: user.password }),
    { headers: { 'Content-Type': 'application/json' } }
  );

  const token = loginRes.json('token');
  const headers = {
    headers: {
      Authorization: `Bearer ${token}`,
      'Content-Type': 'application/json',
    },
  };

  const workspaceIds = [];
  const projectIds = [];

  for (let w = 1; w <= 2; w++) {
    const wsRes = http.post(`${BASE_URL}/workspaces`, JSON.stringify({ name: `WS ${w}` }), headers);
    if (wsRes.status === 201) {
      const wsId = wsRes.json('id');
      workspaceIds.push(wsId);
      for (let p = 1; p <= 2; p++) {
        const projRes = http.post(
          `${BASE_URL}/workspaces/${wsId}/projects`,
          JSON.stringify({ name: `Proj ${p}`, description: 'Seed' }),
          headers
        );
        if (projRes.status === 201) {
          projectIds.push(projRes.json('id'));
        }
      }
    }
  }

  return { token, workspaceIds, projectIds };
}

// 70% Flow: Mostly Reads, occasional Writes
export function tasksAndProjectsFlow(data) {
  const headers = {
    headers: {
      Authorization: `Bearer ${data.token}`,
      'Content-Type': 'application/json',
    },
  };

  const projId = data.projectIds[Math.floor(Math.random() * data.projectIds.length)];

  // Read project & tasks (90% of requests)
  http.get(`${BASE_URL}/projects/${projId}`, headers);
  http.get(`${BASE_URL}/projects/${projId}/tasks`, headers);

  // Write a task occasionally (10% chance)
  if (Math.random() < 0.10) {
    const taskPayload = JSON.stringify({
      title: `Task ${Date.now()}`,
      description: 'Load test item',
      priority: 'Medium',
    });
    http.post(`${BASE_URL}/projects/${projId}/tasks`, taskPayload, headers);
  }

  sleep(0.5);
}

// 15% Flow: Workspaces (Cached)
export function workspacesFlow(data) {
  const headers = {
    headers: {
      Authorization: `Bearer ${data.token}`,
      'Content-Type': 'application/json',
    },
  };

  http.get(`${BASE_URL}/workspaces`, headers);
  if (data.workspaceIds.length > 0) {
    const wsId = data.workspaceIds[Math.floor(Math.random() * data.workspaceIds.length)];
    http.get(`${BASE_URL}/workspaces/${wsId}`, headers);
  }

  sleep(1);
}

// 15% Flow: Profile Verification (Cached)
export function authFlow(data) {
  const headers = {
    headers: {
      Authorization: `Bearer ${data.token}`,
      'Content-Type': 'application/json',
    },
  };

  http.get(`${BASE_URL}/users/me`, headers);
  sleep(1);
}