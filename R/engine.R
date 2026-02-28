evaluate_metrics <- function(sim, obs, metrics) {
  .get_engine()$evaluate(sim = sim, obs = obs, metrics = metrics)
}
