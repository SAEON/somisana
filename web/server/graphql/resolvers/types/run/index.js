export default {
  step1_timestamp: async ({ step1_timestamp }) => new Date(step1_timestamp).toISOString(),
  run_date: async ({ run_date }) => new Date(run_date).toISOString(),
}
