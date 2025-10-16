import React, { useState } from 'react';
import axios from 'axios';
import './App.css';

const API_URL = process.env.REACT_APP_API_URL || 'http://localhost:8000';

function App() {
  const [taskType, setTaskType] = useState('optimize_route');
  const [payload, setPayload] = useState('{"locations": ["A", "B", "C", "D"], "vehicle_type": "truck"}');
  const [taskId, setTaskId] = useState('');
  const [createdTask, setCreatedTask] = useState(null);
  const [retrievedTask, setRetrievedTask] = useState(null);
  const [error, setError] = useState(null);
  const [loading, setLoading] = useState(false);

  const handleCreateTask = async (e) => {
    e.preventDefault();
    setError(null);
    setLoading(true);
    setCreatedTask(null);

    try {
      const parsedPayload = JSON.parse(payload);
      const response = await axios.post(`${API_URL}/api/v1/tasks`, {
        type: taskType,
        payload: parsedPayload
      });
      setCreatedTask(response.data);
      setTaskId(response.data.task.id);
    } catch (err) {
      setError(err.response?.data?.detail || err.message || 'Failed to create task');
    } finally {
      setLoading(false);
    }
  };

  const handleRetrieveTask = async (e) => {
    e.preventDefault();
    setError(null);
    setLoading(true);
    setRetrievedTask(null);

    try {
      const response = await axios.get(`${API_URL}/api/v1/tasks/${taskId}`);
      setRetrievedTask(response.data);
    } catch (err) {
      setError(err.response?.data?.detail || err.message || 'Failed to retrieve task');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="App">
      <div className="container">
        <header className="header">
          <h1>Nexa Task Manager</h1>
          <p>AI-Ready Task Module - Test #1</p>
        </header>

        <div className="forms-container">
          {/* Create Task Form */}
          <div className="card">
            <h2>Create Task</h2>
            <form onSubmit={handleCreateTask}>
              <div className="form-group">
                <label htmlFor="taskType">Task Type</label>
                <select
                  id="taskType"
                  value={taskType}
                  onChange={(e) => setTaskType(e.target.value)}
                  className="input"
                >
                  <option value="optimize_route">Optimize Route</option>
                  <option value="generate_report">Generate Report</option>
                  <option value="analyze_data">Analyze Data</option>
                </select>
              </div>

              <div className="form-group">
                <label htmlFor="payload">Payload (JSON)</label>
                <textarea
                  id="payload"
                  value={payload}
                  onChange={(e) => setPayload(e.target.value)}
                  className="input textarea"
                  rows="5"
                  placeholder='{"key": "value"}'
                />
              </div>

              <button type="submit" className="btn btn-primary" disabled={loading}>
                {loading ? 'Creating...' : 'Create Task'}
              </button>
            </form>
          </div>

          {/* Retrieve Task Form */}
          <div className="card">
            <h2>Retrieve Task</h2>
            <form onSubmit={handleRetrieveTask}>
              <div className="form-group">
                <label htmlFor="taskId">Task ID</label>
                <input
                  id="taskId"
                  type="text"
                  value={taskId}
                  onChange={(e) => setTaskId(e.target.value)}
                  className="input"
                  placeholder="Enter task ID"
                />
              </div>

              <button type="submit" className="btn btn-secondary" disabled={loading || !taskId}>
                {loading ? 'Retrieving...' : 'Get Task'}
              </button>
            </form>
          </div>
        </div>

        {/* Error Display */}
        {error && (
          <div className="alert alert-error">
            <strong>Error:</strong> {error}
          </div>
        )}

        {/* Created Task Display */}
        {createdTask && (
          <div className="card result-card">
            <h2>Task Created Successfully</h2>
            <pre className="json-display">{JSON.stringify(createdTask, null, 2)}</pre>
          </div>
        )}

        {/* Retrieved Task Display */}
        {retrievedTask && (
          <div className="card result-card">
            <h2>Task Details</h2>
            <pre className="json-display">{JSON.stringify(retrievedTask, null, 2)}</pre>
          </div>
        )}
      </div>
    </div>
  );
}

export default App;
