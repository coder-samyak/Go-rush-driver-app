/**
 * Provider boundary for insurance integrations.  A real provider can be
 * injected without changing controllers or exposing provider credentials.
 */
class InsuranceProviderService {
  async getApprovedPolicy() {
    throw new Error('Insurance provider is not configured');
  }

  async submitClaim() {
    throw new Error('Insurance provider is not configured');
  }
}

class MockInsuranceProvider extends InsuranceProviderService {
  async getApprovedPolicy() {
    const configured = process.env.INSURANCE_POLICY_JSON;
    if (configured) {
      try {
        const value = JSON.parse(configured);
        if (value && typeof value === 'object') {
          // Keep provider configuration deliberately narrow: arbitrary JSON
          // could contain credentials or internal integration metadata.
          return {
            code: typeof value.code === 'string' ? value.code : undefined,
            name: typeof value.name === 'string' ? value.name : 'Approved driver insurance policy',
            description: typeof value.description === 'string' ? value.description : 'Policy details are available after enrollment.',
            coverage: typeof value.coverage === 'string' ? value.coverage : 'Coverage details are not currently available.',
            premium: typeof value.premium === 'string' ? value.premium : 'Premium details are not currently available.',
            provider: typeof value.provider === 'string' ? value.provider : 'Provider details are not currently available.',
          };
        }
      } catch (_) {
        // Invalid configuration must never break the API or leak its value.
      }
    }
    return {
      name: process.env.INSURANCE_POLICY_NAME || 'Approved driver insurance policy',
      description: process.env.INSURANCE_POLICY_DESCRIPTION || 'Policy details are available after enrollment.',
      coverage: process.env.INSURANCE_POLICY_COVERAGE || 'Coverage details are not currently available.',
      premium: process.env.INSURANCE_POLICY_PREMIUM || 'Premium details are not currently available.',
      provider: process.env.INSURANCE_PROVIDER_NAME || 'Provider details are not currently available.',
    };
  }

  async submitClaim(claim) {
    return { accepted: true, reference: `GR-CLM-${String(claim._id).slice(-8).toUpperCase()}` };
  }
}

module.exports = { InsuranceProviderService, MockInsuranceProvider };
