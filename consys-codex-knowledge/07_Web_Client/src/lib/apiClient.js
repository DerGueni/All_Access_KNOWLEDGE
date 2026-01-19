/**
 * API-Client für Backend-Kommunikation
 */

const API_BASE_URL = 'http://localhost:3000/api';

/**
 * Fetch-Helper mit Error-Handling
 */
async function apiFetch(url, options = {}) {
  try {
    const response = await fetch(`${API_BASE_URL}${url}`, {
      ...options,
      headers: {
        'Content-Type': 'application/json',
        ...options.headers,
      },
    });

    if (!response.ok) {
      const error = await response.json();
      throw new Error(error.error || `HTTP ${response.status}`);
    }

    return await response.json();
  } catch (error) {
    console.error(`API Error [${url}]:`, error);
    throw error;
  }
}

/**
 * Mitarbeiter-API
 */
export const MitarbeiterAPI = {
  /**
   * Holt alle Mitarbeiter
   */
  getAll: async () => {
    return apiFetch('/mitarbeiter');
  },

  /**
   * Holt einen Mitarbeiter nach ID
   */
  getById: async (id) => {
    return apiFetch(`/mitarbeiter/${id}`);
  },

  /**
   * Erstellt neuen Mitarbeiter
   */
  create: async (data) => {
    return apiFetch('/mitarbeiter', {
      method: 'POST',
      body: JSON.stringify(data),
    });
  },

  /**
   * Aktualisiert Mitarbeiter
   */
  update: async (id, data) => {
    return apiFetch(`/mitarbeiter/${id}`, {
      method: 'PUT',
      body: JSON.stringify(data),
    });
  },

  /**
   * Löscht Mitarbeiter
   */
  delete: async (id) => {
    return apiFetch(`/mitarbeiter/${id}`, {
      method: 'DELETE',
    });
  },
};

/**
 * Kunden-API
 */
export const KundenAPI = {
  /**
   * Holt alle Kunden
   * @param {Object} filters - Optional: { aktiv: boolean, plz: string, ort: string }
   */
  getAll: async (filters = {}) => {
    const params = new URLSearchParams();
    if (filters.aktiv !== undefined) params.append('aktiv', filters.aktiv);
    if (filters.plz) params.append('plz', filters.plz);
    if (filters.ort) params.append('ort', filters.ort);
    if (filters.sortfeld) params.append('sortfeld', filters.sortfeld);

    const queryString = params.toString();
    return apiFetch(`/kunden${queryString ? '?' + queryString : ''}`);
  },

  /**
   * Holt einen Kunden nach ID
   */
  getById: async (id) => {
    const result = await apiFetch(`/kunden/${id}`);
    return result.data;
  },

  /**
   * Erstellt neuen Kunden
   */
  create: async (data) => {
    const result = await apiFetch('/kunden', {
      method: 'POST',
      body: JSON.stringify(data),
    });
    return result.data;
  },

  /**
   * Aktualisiert Kunden
   */
  update: async (id, data) => {
    const result = await apiFetch(`/kunden/${id}`, {
      method: 'PUT',
      body: JSON.stringify(data),
    });
    return result.data;
  },

  /**
   * Löscht Kunden
   */
  delete: async (id) => {
    return apiFetch(`/kunden/${id}`, {
      method: 'DELETE',
    });
  },

  /**
   * Holt Umsatz-Statistiken
   */
  getUmsatz: async (id) => {
    const result = await apiFetch(`/kunden/${id}/umsatz`);
    return result.data;
  },
};

/**
 * Health-Check
 */
export async function checkHealth() {
  return apiFetch('/health');
}
