import React, { useEffect, useState } from 'react'
import { fetchClubs } from './api'

export default function App() {
  const [clubs, setClubs] = useState([])

  useEffect(() => {
    fetchClubs().then(setClubs).catch(console.error)
  }, [])

  return (
    <div style={{ padding: 20, fontFamily: 'Arial, sans-serif' }}>
      <h1>MT Book Clubs</h1>
      <p>Minimal scaffold — list of clubs:</p>
      <ul>
        {clubs.map(c => (
          <li key={c._id}>
            <strong>{c.name}</strong> — {c.description}
          </li>
        ))}
      </ul>
    </div>
  )
}
