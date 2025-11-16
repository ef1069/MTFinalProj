const API = import.meta.env.VITE_API_URL || 'http://localhost:5000'

export async function fetchClubs() {
  const res = await fetch(`${API}/api/clubs`)
  if (!res.ok) throw new Error('Failed to fetch clubs')
  return res.json()
}
