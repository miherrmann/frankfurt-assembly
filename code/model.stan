// Estimation of member ideology from voting behaviour
// Two parameter item-response model
// Two latent dimensions


data {
  
  int<lower=1> N;
  int<lower=1> I;
  int<lower=1> J;
  array[N] int<lower=0, upper=1> behaviour;
  array[N] int<lower=1, upper=I> member;
  array[N] int<lower=1, upper=J> vote;
  array[J - 1] int<lower=1> not_vote_left;
  array[J - 1] int<lower=1> not_vote_up;
  int<lower=1> vote_left;
  int<lower=1> vote_up;

}

parameters {
  
  vector[I] x_1_star;
  vector[I] x_2_star;
  vector[J] alpha_star;
  vector[J - 1] beta_1_star_free;
  vector[J - 1] beta_2_star_free;

}

transformed parameters {

  vector[J] beta_1_star = rep_vector(0, J);
  vector[J] beta_2_star = rep_vector(0, J);

  beta_1_star[not_vote_up] = beta_1_star_free;
  beta_2_star[not_vote_left] = beta_2_star_free;

}

model {
  
  alpha_star ~ normal(0, 10);
  beta_1_star_free ~ normal(0, 10);
  beta_2_star_free ~ normal(0, 10);
  x_1_star ~ std_normal();
  x_2_star ~ std_normal();

  behaviour ~ bernoulli_logit(
    alpha_star[vote] 
    + beta_1_star[vote] .* x_1_star[member] 
    + beta_2_star[vote] .* x_2_star[member]
  );

}

generated quantities {
  
  int<lower=-1, upper=1> sign_1;
  int<lower=-1, upper=1> sign_2;
  vector[I] x_1;
  vector[I] x_2;
  vector[J] alpha;
  vector[J] beta_1;
  vector[J] beta_2;
  real mean_x_1 = mean(x_1_star);
  real mean_x_2 = mean(x_2_star);
  real sd_x_1 = sd(x_1_star);
  real sd_x_2 = sd(x_2_star);
  
  sign_1 = beta_1_star[vote_left] < 0 ? 1 : -1;
  sign_2 = beta_2_star[vote_up] > 0 ? 1 : -1;
  x_1 = sign_1 * (x_1_star - mean_x_1) / sd_x_1;
  x_2 = sign_2 * (x_2_star - mean_x_2) / sd_x_2;
  beta_1 = sign_1 * beta_1_star * sd_x_1;
  beta_2 = sign_2 * beta_2_star * sd_x_2;
  alpha = alpha_star + sign_1 * beta_1_star * mean_x_1
    + sign_2 * beta_2_star * mean_x_2;

}
