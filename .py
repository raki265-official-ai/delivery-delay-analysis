import numpy as np
import pandas as pd
import matplotlib.pyplot  as Plt



# Create output directory if it does not exist
Path("outputs").mkdir(parents=True, exist_ok=True)

# Relative paths
deliveries_path = "data/raw/deliveries.csv"
routes_path = "data/raw/routes.csv"

# Load raw CSV files
deliveries = pd.read_csv(deliveries_path)
routes = pd.read_csv(routes_path)

print("Deliveries shape:", deliveries.shape)
print("Routes shape:", routes.shape)

display(deliveries.head())
display(routes.head())



# Remove exact duplicate rows
before = len(deliveries)

deliveries = deliveries.drop_duplicates().copy()

after = len(deliveries)

print("Rows before duplicate removal:", before)
print("Rows after duplicate removal:", after)
print("Duplicate rows removed:", before - after)

# Left join deliveries with routes
df = deliveries.merge(
    routes,
    on="route_id",
    how="left",
    validate="many_to_one"
)

print("Merged DataFrame shape:", df.shape)

# Required assertions
assert len(df) == 12, "Merged DataFrame must contain exactly 12 rows"
assert df["service_type"].isna().sum() == 0, \
    "There are unmatched route_id values"

print("12-row assertion: PASSED")
print("Zero unmatched route_id assertion: PASSED")

display(df)



# Calculate non-negative delay
df["delay_days"] = (
    df["actual_days"] - df["promised_days"]
).clip(lower=0)

display(df)



# Ensure chronological month order
month_order = ["Jan", "Feb", "Mar"]

monthly_delay = (
    df.groupby("month")["delay_days"]
      .sum()
      .reindex(month_order)
)

print("Monthly total delay:")
display(monthly_delay.reset_index(name="total_delay_days"))

# Plot
plt.figure(figsize=(8, 5))

monthly_delay.plot(
    kind="bar",
    color=["#4C78A8","#F58518", "#54A24B"]
)

plt.title("Monthly Total Delay Days")
plt.xlabel("Month")
plt.ylabel("Total Delay Days")
plt.xticks(rotation=0)

plt.tight_layout()

# Save chart
plt.savefig("outputs/python_chart.png", dpi=300, bbox_inches="tight")

plt.show()







