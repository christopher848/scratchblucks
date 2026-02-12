# scratchblucks
anotherwebsitecopycat
/**
 * Simple Search Engine Implementation
 * Supports keyword search, filtering, and ranking
 */

class SearchEngine {
  constructor() {
    this.documents = [];
    this.index = new Map();
    this.results = [];
  }

  /**
   * Add a document to the search engine
   * @param {Object} doc - Document with id, title, content
   */
  addDocument(doc) {
    if (!doc.id || !doc.content) {
      throw new Error('Document must have id and content');
    }
    
    this.documents.push(doc);
    this.indexDocument(doc);
  }

  /**
   * Index a document for fast searching
   * @param {Object} doc - Document to index
   */
  indexDocument(doc) {
    const words = this.tokenize(doc.content);
    
    words.forEach(word => {
      if (!this.index.has(word)) {
        this.index.set(word, []);
      }
      
      const docs = this.index.get(word);
      if (!docs.includes(doc.id)) {
        docs.push(doc.id);
      }
    });
  }

  /**
   * Tokenize content into searchable words
   * @param {string} content - Content to tokenize
   * @returns {Array} Array of normalized words
   */
  tokenize(content) {
    return content
      .toLowerCase()
      .replace(/[^\w\s]/g, '')
      .split(/\s+/)
      .filter(word => word.length > 2);
  }

  /**
   * Search for documents matching query
   * @param {string} query - Search query
   * @param {Object} options - Search options
   * @returns {Array} Ranked search results
   */
  search(query, options = {}) {
    const {
      limit = 10,
      filter = null,
      sortBy = 'relevance'
    } = options;

    const words = this.tokenize(query);
    const scores = new Map();

    // Score documents based on keyword matches
    words.forEach(word => {
      const matchingDocs = this.index.get(word) || [];
      
      matchingDocs.forEach(docId => {
        const currentScore = scores.get(docId) || 0;
        scores.set(docId, currentScore + 1);
      });
    });

    // Convert to results array
    let results = Array.from(scores.entries()).map(([docId, score]) => {
      const doc = this.documents.find(d => d.id === docId);
      return {
        ...doc,
        relevanceScore: score,
        matchedKeywords: words.filter(w => 
          this.tokenize(doc.content).includes(w)
        )
      };
    });

    // Apply filters
    if (filter) {
      results = results.filter(filter);
    }

    // Sort results
    if (sortBy === 'relevance') {
      results.sort((a, b) => b.relevanceScore - a.relevanceScore);
    } else if (sortBy === 'date') {
      results.sort((a, b) => new Date(b.date) - new Date(a.date));
    }

    return results.slice(0, limit);
  }

  /**
   * Get all indexed documents
   * @returns {Array} All documents
   */
  getAllDocuments() {
    return this.documents;
  }

  /**
   * Clear the search engine
   */
  clear() {
    this.documents = [];
    this.index.clear();
  }
}

// Export for use
module.exports = SearchEngine;
