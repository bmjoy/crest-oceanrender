
#define LOWER_RANGE 256.0
#define LOWER_USED 127.0

// returns value in [0,1]
float UnPackFoam_CurrentValue(float packedValue)
{
	return min(fmod(packedValue, LOWER_RANGE) / LOWER_USED, 1.);
}
// returns value in [0,1]
float UnPackFoam_AccumValue(float packedValue)
{
	return min(1., (packedValue - fmod(packedValue, LOWER_RANGE)) / (LOWER_USED*LOWER_RANGE));
}
// assumes value is in [0,1]!
float PackFoam_CurrentValue(float value)
{
	return min(value,1.) * LOWER_USED;
}
// assumes value is in [0,1]!
float PackFoam_AccumValue(float value)
{
	float result = min(value,1.) * LOWER_USED * LOWER_RANGE;
	result -= fmod(result, LOWER_RANGE);
	return result;
}

float PackFoam(float curValue, float accumValue)
{
	return PackFoam_CurrentValue(curValue) + PackFoam_AccumValue(accumValue);
}
void UnPackFoam(float packedValue, out float curValue, out float accumValue)
{
	curValue = UnPackFoam_CurrentValue(packedValue);
	accumValue = UnPackFoam_AccumValue(packedValue);
}
